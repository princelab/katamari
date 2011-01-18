require 'katamari/msconvert/mounted_server'

class Katamari
  class Msconvert
    module MountedServer
      class Server
        include MountedServer

        def initialize(msconvert_cmd, port=MountedServer::DEFAULT_PORT, base_dir="/")
          @msconvert_cmd = msconvert_cmd
          check_no_spaces(base_dir)
          @mapper = MountMapper.new(base_dir)
          @port = port
        end

        def run
          server = TCPServer.new(@port)
          loop do
            Thread.start(self, server.accept, Thread.current) do |srv_obj, client, parent_thread|

              puts "accepted client: #{client}"
              begin
                srv_obj.serve(client) 
              rescue Exception => e
                parent_thread.raise e
              end
              
            end
          end
        end

        def serve(client)
          rel_filename = client.gets.chomp
          reply = nil
          cmd_to_execute = 
            if rel_filename == MountedServer::CUE_FOR_HELP
              @msconvert_cmd
            else
              (output_path_from_basedir, other_args_st) = 2.times.map { client.gets.chomp }
              new_ext = expected_extension(other_args_st)
              basename = @mapper.basename(rel_filename) 
              full_path_to_rawfile = @mapper.full_path(rel_filename)
              full_output_dir_path = @mapper.full_path(output_path_from_basedir)
              FileUtils.mkpath(full_output_dir_path) unless File.directory?(full_output_dir_path)
              fs = File::SEPARATOR
              cmd = [@msconvert_cmd, full_path_to_rawfile.gsub("/",fs), "-o " + full_output_dir_path.gsub("/",fs), other_args_st].join(" ")
              # should sanitize the input since we're running it all in one command
              cmd
            end
          pipe_stderr_to_stdout = '2>&1'
          begin
            puts "executing: #{cmd_to_execute} #{pipe_stderr_to_stdout}"
            reply = `#{cmd_to_execute}  #{pipe_stderr_to_stdout}`
            puts "********************** <start msconvert output> ***************************"
            puts reply
            puts "*********************** <end msconvert output> ****************************"
            client.puts wrap_reply(reply)
          rescue
            client.puts wrap_reply($!)
          ensure
            client.close
          end
        end
      end
    end
  end
end
