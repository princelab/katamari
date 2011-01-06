#!/usr/bin/ruby

require 'optparse'
require 'katamari/msconvert'

###############################################################################
# This configuration assumes that the local computer and remote server
# both have access to the same filesystem
#
# SETTINGS: 
$VERBOSE = true

# ip address of computer running msconvert_server.rb
SERVER_IP = "192.168.101.185"
PORT = 22007

# client mount point (client side equivalent to msconvert_server.rb)
BASE_DIR = "#{ENV["HOME"]}/lab"

# A tmp directory should also exist under the mount for files that aren't
# already in the path
MOUNT_TMP_DIR = "tmp" 
###############################################################################

def putsv(*args)
 puts *args if $VERBOSE
end

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} file.RAW <msconvert_options>"
  puts "outputs: file.mz[X]ML"
  exit
end

(filename, *options) = ARGV
options_st = options.join(" ")

full_path = File.expand_path(filename)

(full_path_parts, base_dir_parts) = [full_path,BASE_DIR].map {|fn| fn.split(/[\/\\]/) }

under_mount = (full_path_parts[0,base_dir_parts.size] == base_dir_parts)

# the file is already located under the mount
rel_path = 
  if under_mount
    putsv "file is already under the mount point (this is good)"
    File.join(full_path_parts[base_dir_parts.size..-1])
  else # the file must be moved under the mount
    raise NotImplementedError, "haven't got this working yet"
  end

converter = Katamari::Msconvert.new(SERVER_IP, PORT)

output_rel_path = converter.convert(rel_path, options_st)
output_full_path = File.join(BASE_DIR, output_rel_path)

if under_mount
  putsv "created: #{output_full_path}"
else
end

