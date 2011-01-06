require 'socket'
require 'fileutils'

## by default, will specify the output directory to be the path of the input
## directory


PORT = 22007

# this is the root where you want all conversion to take place
BASE_DIR = 'S:'
MSCONVERT_CMD = "msconvert.exe"

server = TCPServer.open(port) # Socket to listen on port 2200
loop do
  client = server.accept

  (rawfilename_with_input_path_from_basedir, output_path_from_basedir, other_args) = 3.times.map { client.gets.chomp }

  full_path_to_rawfile = File.join(BASE_DIR, rawfilename_with_input_path_from_basedir)
  full_output_dir_path = File.join(BASE_DIR, output_path_from_basedir)

  FileUtils.mkpath(full_output_dir_path)
  
  puts "Received and processed data:"
  puts "  Full path to rawfile : #{full_path_to_rawfile}"
  puts "  Full path to outdir  : #{full_output_dir_path}"
  puts "  Other arguments: #{other_args}"

  cmd = [MSCONVERT_CMD, full_path_to_rawfile, "-o #{output_path_from_basedir}", other_args]
  puts "running (safe mode): #{cmd.join(" ")}"
  
  # It's lame to have a script run a script, but it's the only way to get this to work.
  #system "scriptit.bat " + filename + ".raw"
  
  puts "Output file in: #{full_output_dir_path}"
  puts "Output file is: #{full_output_dir_path}"
  client.close # Disconnect from the client
end