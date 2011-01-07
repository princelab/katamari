#!/usr/bin/env ruby

require 'socket'
require 'fileutils'
require 'shellwords'

################################################################################
# SETTINGS:
MSCONVERT_CMD = "msconvert.exe"
PORT = 22007
BASE_DIR = 'S:'
################################################################################

## by default, will specify the output directory to be the path of the input
## directory

puts "starting up #{File.basename(__FILE__)} and listening..."

# this is the root where you want all conversion to take place

server = TCPServer.open(PORT) # Socket to listen on port 2200
loop do
  client = server.accept
  rawfilename_with_input_path_from_basedir = client.gets.chomp
  if rawfilename_with_input_path_from_basedir == "--help"
    reply = `#{MSCONVERT_CMD} 2>&1`
    client.puts reply
  else
    (output_path_from_basedir, other_args) = 2.times.map { client.gets.chomp }

    new_ext = other_args["--mzXML"] ? ".mzXML" : ".mzML"

    basename = rawfilename_with_input_path_from_basedir.split(/[\/\\]/).last
    base_noext = basename.chomp(File.extname(basename))

    full_path_to_rawfile = File.join(BASE_DIR, rawfilename_with_input_path_from_basedir)
    full_output_dir_path = File.join(BASE_DIR, output_path_from_basedir)
    full_outputfile_path = File.join(full_output_dir_path, base_noext + new_ext)

    FileUtils.mkpath(full_output_dir_path)

    fs = File::SEPARATOR
    cmd = [MSCONVERT_CMD, full_path_to_rawfile.gsub("/",fs), "-o " + full_output_dir_path.gsub("/",fs), other_args].join(" ")
    # should sanitize the input since we're running it all in one command

    system cmd

    client.puts "done"
    puts "executed: #{cmd}"
  end
  client.close # Disconnect from the client
end
