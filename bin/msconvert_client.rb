#!/usr/bin/env ruby

require 'fileutils'
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

opts = OptionParser.new do |op|
  op.on("-h", "--help") do
    puts Katamari::Msconvert.new(SERVER_IP, PORT).usage
  end
end
opts.parse!

if ARGV.size == 0
  op.banner = "usage: #{File.basename(__FILE__)} file.RAW <msconvert_options>"
  op.separator "outputs: file.mzML (or other extension)"
  puts 
  exit
end

(filename, *options) = ARGV
options_st = options.join(" ")

input_full_path = File.expand_path(filename)
input_file_basename = File.basename(filename)

output_dir = File.dirname(input_full_path) # only need for files not under the base

(input_full_path_parts, base_dir_parts) = [input_full_path,BASE_DIR].map {|fn| fn.split(/[\/\\]/) }

under_mount = (input_full_path_parts[0,base_dir_parts.size] == base_dir_parts)

tmp_dir = File.join(BASE_DIR, MOUNT_TMP_DIR)

# the file is already located under the mount
rel_path = 
  if under_mount
    putsv "file is under the mount point: #{BASE_DIR}"
    File.join(input_full_path_parts[base_dir_parts.size..-1])
  else # the file must be moved under the mount
    FileUtils.cp(filename, tmp_dir)
    putsv "copying under mount: #{File.join(tmp_dir, input_file_basename)}"
    File.join(MOUNT_TMP_DIR, input_file_basename)
  end

converter = Katamari::Msconvert.new(SERVER_IP, PORT)

output_rel_path = converter.convert(rel_path, options_st)
output_full_path = File.join(BASE_DIR, output_rel_path)
basename = output_full_path.split(/[\/\\]/).last


if under_mount
  putsv "            created: #{output_full_path}"
else
  putsv "   msconvert output: #{output_full_path}"
  putsv "          moving to: #{output_dir}"
  FileUtils.mv(output_full_path, output_dir)
  outputfile = File.join(output_dir, basename)
  putsv "            created: #{outputfile}"
end

