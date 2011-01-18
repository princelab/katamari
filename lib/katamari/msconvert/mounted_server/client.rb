require 'katamari/msconvert/mounted_server'

class Katamari
  class Msconvert
    module MountedServer
      class Client
        include MountedServer

        attr_accessor :server_ip, :port

        # server_ip and port should match those of the computer running
        # msconvert_server.rb
        def initialize(server_ip, port)
          (@server_ip, @port) = server_ip, port
        end

        def usage
          server = TCPSocket.open(@server_ip, @port)
          server.puts MountedServer::CUE_FOR_HELP
          reply = cleanup_reply(get_reply(server))
          server.close
          reply
        end

        # the mount dir is expected to match up with the server mount dir (in
        # terms of the files on it, not the value itself necessarily)
        # basically, this ensures that the file is under the proper mount
        # (copies it if necessary).
        def convert_on_client(filename, other_args_st, mount_dir, tmp_subdir=DEFAULT_MOUNT_TMP_SUBDIR)
          mm = MountMapper.new(mount_dir, tmp_subdir)
          under_mount = mm.under_mount?(filename)
          full_filename_under_mount = 
            if under_mount
              File.expand_path(filename)
            else
              mm.cp_under_mount(filename)
            end
          (rel_output, msconvert_reply) = convert_on_server(mm.relative_path(full_filename_under_mount), other_args_st)
          full_output = mm.full_path(rel_output)

          unless File.exist?(full_output)
            msg = []
            msg << "!!!!--> expected output file does not exist under the mount! <--!!!!"
            msg << "!!!!--> expected: #{full_output} <--!!!!"
            msg << "****************** <start msconvert output> *******************"
            msg << msconvert_reply
            msg << "******************* <end msconvert output> ********************"
            $stderr.puts msg.join("\n")
            raise RuntimeError, "expected output file does not exist as described above!"
          end

          output_path = 
            if under_mount
              full_output
            else
              outdir = File.dirname(File.expand_path(filename))
              final_output = File.join(outdir, File.basename(full_output))
              FileUtils.mv(full_output, final_output)
              final_output
            end
          raise RuntimeError, "output file does not exist!" unless File.exist?(output_path)
          [output_path, msconvert_reply]
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
        # By default, the output path will be the same directory as the file is
        # found in.  Will remove the -o/--outdir option.  Use
        # relative_output_dir argument instead.
        def convert_on_server(relative_path_on_server, other_args_st="", relative_output_dir=nil)
          [relative_path_on_server, relative_output_dir].each {|path| check_no_spaces(path) }
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
end
