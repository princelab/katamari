require 'pathname'
require 'socket'
require 'fileutils'

class Katamari
  # provides a simple TCP server/client architecture for converting files
  # depends on a computer running msconvert_server.rb (found in bin dir)
  class Msconvert
    class TCP
      class MountMapper
        attr_accessor :client_mount_dir
        attr_reader :client_mount_dir_pieces
        def initialize(client_mount_dir)
          @client_mount_dir = File.expand_path(client_mount_dir)
          @client_mount_dir_pieces = split_filename(@client_mount_dir)
        end

        def split_filename(fn)
          fn.split(/[\/\\]/)
        end

        def under_mount?(filename)
          split_filename(File.expand_path(filename))[0,@client_mount_dir_pieces.size] == @client_mount_dir_pieces
        end

        # assumes the file is already under the mount
        # returns its path relative to the mount
        def relative_path(filename)
          pieces = split_filename(File.expand_path(filename))
          File.join(pieces[@client_mount_dir_pieces.size..-1])
        end

        # move the file under the mount (and optionally to a subdirectory under the mount)
        # returns the expanded path of the file
        def cp_under_mount(filename, mount_subdir=nil)
          dest = File.join(@client_mount_dir, mount_subdir || "", File.basename(filename))
          FileUtils.cp( filename, dest )
          dest
        end

        def full_path(relative_filename)
          File.join(@client_mount_dir, relative_filename)
        end
        
      end

      CONFIG = {
        :convert_folder => 'tmp'
      }

      attr_accessor :server_ip, :port

      # server_ip and port should match those of the computer running
      # msconvert_server.rb
      def initialize(server_ip, port)
        (@server_ip, @port) = server_ip, port
      end

      def live?
      end

      def usage
        server = TCPSocket.open(@server_ip, @port)
        server.puts "--help"
        reply = server.read
        server.close
        reply
      end

      def expected_extension(args)
        if args["--mzXML"]
          ".mzXML"
        elsif args["--mgf"]
          ".mgf"
        elsif args["--text"]
          ".txt"
        else ; ".mzML"
        end
      end

      # the mount dir is expected to match up with the server mount dir (in
      # terms of the files on it, not the value itself necessarily)
      # basically, this ensures that the file is under the proper mount
      # (copies it if necessary).
      def convert_on_client(filename, other_args_st, mount_dir, subdir=nil)
        mm = MountMapper.new(mount_dir)
        under_mount = mm.under_mount?(filename)
        full_filename_under_mount = 
          if under_mount
            File.expand_path(filename)
          else
            mm.cp_under_mount(filename, subdir)
          end
        rel_output = convert_on_server(mm.relative_path(full_filename_under_mount), other_args_st)
        full_output = mm.full_path(rel_output)

        if under_mount
          full_output
        else
          outdir = File.dirname(File.expand_path(filename))
          final_output = File.join(outdir, File.basename(full_output))
          FileUtils.mv(full_output, final_output)
          final_output
        end
      end

      # if the BASE_DIR on the server is 'S:', then you are only specifying the
      # relative path from there (use unix style slashes)
      #
      #     # file on server is "S:/RAW/tmp/test.raw" with BASE_DIR 'S:'
      #     Katamari::Msconvert.convert("RAW/tmp/test.raw")
      #
      # returns the relative path (from BASE_DIR) to the output file and the
      # output: [rel_path, conversion_output]
      def convert_on_server(relative_path_on_server, other_args_st="")
        new_ext = expected_extension(other_args_st)
        pn = Pathname.new(relative_path_on_server) 
        outputdir = pn.dirname
        (path, fn) = pn.split

        rel_outfile = File.join(outputdir, fn.sub_ext(new_ext))

        server = TCPSocket.open(@server_ip, @port)

        server.puts relative_path_on_server
        server.puts outputdir
        server.puts other_args_st

        reply = nil
        loop do
          reply = server.read
          break if reply =~ /done/
          sleep 0.5
          print "."
        end
        [rel_outfile, reply]
      end
    end
  end
end
