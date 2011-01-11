#!/usr/bin/env ruby

require 'fileutils'
require 'katamari/msconvert'

###############################################################################
# This configuration assumes that the local computer and remote server
# both have access to the same filesystem

# ip address of computer running msconvert_server.rb
SERVER_IP = "192.168.101.185"
# can change if you also set it for the server
PORT = Katamari::Msconvert::TCP::DEFAULT_PORT

# client mount point (client side equivalent to msconvert_server.rb)
BASE_DIR = "#{ENV['HOME']}/lab"

# A tmp directory should also exist under the mount for files that aren't
# already in the path
MOUNT_TMP_DIR = "tmp" 
###############################################################################

$VERBOSE = (ARGV.include?("-v") || ARGV.include?("--verbose"))

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} [OPTIONS] <file>.raw ..."
  puts "output:  <file>.mzML ..."
  puts "--mzXML  <file>.mzXML ..."
  puts "--mgf    <file>.mgf ..."
  puts "--text   <file>.txt ..."
  puts ""
  puts "options:"
  puts "        --msconvert-help     show msconvert usage and exit"
  puts "    -v  --verbose" 
  puts ""
  puts "*** passes through ALL msconvert options ***"
  puts "avoid these opts (unecessary): -f/--filelist and -e/--ext"
  exit
end

begin
  client = Katamari::Msconvert::TCP.new(SERVER_IP, PORT)
rescue Errno::ETIMEDOUT
  abort "can't seem to be able to reach the server at that port! (exiting)"
end

if ARGV.include?("--msconvert-help")
  puts client.usage
  exit
end

unless (ARGV.include?("-z") || ARGV.include?("--zlib"))
  if ARGV.include?("--no-compress")
    ARGV.delete("--no-compress")
  elsif ARGV.include?("--mgf") || ARGV.include?("--text")
    # okay to not compress
  else
    msg = []
    msg << ""
    msg << "************************************************************"
    msg << "I'm pretty sure you wanted binary data compression!"
    msg << "Run with '--no-compress' to override this behavior"
    msg << "or '-z' to zlib compress your binary data."
    msg << "************************************************************"
    raise ArgumentError, msg.join("\n")
  end
end

(args, files) = ARGV.partition {|v| v[/^-/] }
option_string = args.join(" ")

files.each do |file|
  (output_file, msg) = client.convert_on_client(file, option_string, BASE_DIR, MOUNT_TMP_DIR)
  puts "*************** <begin msconvert output> ******************"
  puts msg
  puts "**************** <end msconvert output> *******************"
  puts "created: #{output_file}"
end
