require 'pathname'
require 'socket'
require 'fileutils'

class Katamari
  # provides a simple TCP server/client architecture for converting files
  # depends on a computer running msconvert_server.rb (found in bin dir)
  class Msconvert
    class TCP
      DEFAULT_PORT = 22907  # arbitrary
      MSCONVERT_CMD_WIN = "msconvert.exe"

      class MountMapper
        attr_accessor :mount_dir
        attr_reader :mount_dir_pieces
        def initialize(mount_dir)
          @mount_dir = File.expand_path(mount_dir)
          @mount_dir_pieces = split_filename(@mount_dir)
        end

        # OS independent filename splitter "/path/to/file" =>
        # ['path','to','file']
        def split_filename(fn)
          fn.split(/[\/\\]/)
        end

        # OS independent basename getter
        def basename(fn)
          split_filename(fn).last
        end

        def under_mount?(filename)
          split_filename(File.expand_path(filename))[0,@mount_dir_pieces.size] == @mount_dir_pieces
        end

        # assumes the file is already under the mount
        # returns its path relative to the mount
        def relative_path(filename)
          pieces = split_filename(File.expand_path(filename))
          File.join(pieces[@mount_dir_pieces.size..-1])
        end

        # move the file under the mount (and optionally to a subdirectory under the mount)
        # returns the expanded path of the file
        def cp_under_mount(filename, mount_subdir=nil)
          dest = File.join(@mount_dir, mount_subdir || "", File.basename(filename))
          FileUtils.cp( filename, dest )
          dest
        end

        def full_path(relative_filename)
          File.join(@mount_dir, relative_filename)
        end
      end

      def self.wrap_reply(st)
        "<reply>\n#{st}\n</reply>"
      end

      def self.msconvert_server(msconvert_cmd, client, base_dir="/")
        rel_filename = client.gets.chomp
        reply = nil
        if rel_filename == "--help"
          reply = `#{msconvert_cmd} 2>&1`
          puts "executed: #{msconvert_cmd}"
        else
          (output_path_from_basedir, other_args_st) = 2.times.map { client.gets.chomp }
          new_ext = expected_extension(other_args_st)
          mm = MountMapper.new(base_dir)
          basename = mm.basename(rel_filename) 
          full_path_to_rawfile = mm.full_path(rel_filename)
          full_output_dir_path = mm.full_path(output_path_from_basedir)
          FileUtils.mkpath(full_output_dir_path)
          fs = File::SEPARATOR
          cmd = [msconvert_cmd, full_path_to_rawfile.gsub("/",fs), "-o " + full_output_dir_path.gsub("/",fs), other_args].join(" ")
          # should sanitize the input since we're running it all in one command
          reply = `#{cmd} 2>&1`
          puts "executed: #{cmd}"
        end
        client.puts wrap_reply(reply)
      end

      attr_accessor :server_ip, :port

      # server_ip and port should match those of the computer running
      # msconvert_server.rb
      def initialize(server_ip, port)
        (@server_ip, @port) = server_ip, port
      end

      def usage
        server = TCPSocket.open(@server_ip, @port)
        server.puts "--help"
        reply = cleanup_reply(get_reply(server))
        server.close
        reply
      end

      # takes the argument string and determines what the output file
      # extension will be.  Doesn't work on the -e/--ext flag yet.
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

      # cleans the reply and also uses newline as line separator
      def cleanup_reply(reply)
        pieces = reply.split(/\n\r?/)
        header_i = pieces.index {|v| v =~ /<reply>/ }
        trailer_i = pieces.rindex {|v| v =~ /<\/reply>/ }
        pieces[(header_i+1)...trailer_i].join("\n")
      end

      # loops and reads from the server until the end reply is sent
      def get_reply(server)
        # TODO: add a timeout?
        reply = ""
        loop do
          reply << server.read
          break if reply =~ /<\/reply>/m
          p reply
          puts "LISTENING"
          sleep 0.2
        end
        reply
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

        reply = cleanup_reply(get_reply(server))
        server.close
        [rel_outfile, reply]
      end
    end
  end
end
