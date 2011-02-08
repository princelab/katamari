#!/usr/bin/env ruby

require 'babypool'
require 'katamari/util'
require 'sane/os'

######################################################################
# see: https://github.com/princelab/katamari/wiki/msconvert-on-linux
# CONSTANTS:
MSCONVERT_BASE_CMD = 
  if OS.windows?
    "msconvert.exe"
  else
    # I just put the unzipped pwiz binary directory in this location
    # change to suit your tastes:
    "wine /usr/local/pwiz-win/msconvert.exe"
  end


# could set to 2 or 4 also
CORES_TO_USE = Katamari::Util.number_of_processors
######################################################################

def has_args?(array, *others)
  others.any? {|fl| array.include?(fl) }
end

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} /path/to/<file>.raw ..."
  puts "outputs: /path/to/<file>.mzXML ..."
  puts "  applicable arguments are passed through"
  puts "  avoid -e/--ext unless necessary to specify file extension (rather than type)"
  puts "  if using wine, automatically turns off multithreading"
  puts ""
  puts "flags passed in by default (you don't need to set them):"
  puts "  --zlib             use --no-compress to remove"
  puts "  --mzXML            use --mzML/--mgf/--text to override"
  puts "  --outdir           defaults to the directory the file sits in"
  puts "                     (set this value to overide the default)"
  puts ""
  puts "other options:"
  puts "  --show-wine-msg    shows all wine output"
  puts "  --no-multithread   don't multithread"
  puts "  --msconvert-usage  show msconvert help message"
  exit
end

(files, options, flags) = Katamari::Util.classify_arguments(ARGV, %w(-f --filelist -o --outdir -c --config -e --ext -i --contactInfo --filter))

ext_opt = options.find {|opt,val| opt =~ /^(-e|--ext)/ }

# use mzXML unless another filetype is specified
filetype_flags = %w(mzML mgf text ms2 cms2).map {|v| "--" << v }
unless has_args?(flags, *filetype_flags)
  unless flags.include?("--mzXML")
    flags << "--mzXML"
  end
end

# add on -z unless --no-compress is specified
unless has_args?(flags, "-z", "--zlib", "--no-compress")
  flags << "-z"
end

has_outdir = has_args?(options.flatten, "-o", "--outdir")
using_filelist = has_args?(options.flatten, "-f", "--filelist")

msconvert_command = 
  if !flags.delete("--show-wine-msg") && MSCONVERT_BASE_CMD[/^wine/]
    "export WINEDEBUG=fixme-all,err-all,warn-all,trace-all && " << MSCONVERT_BASE_CMD
  else
    MSCONVERT_BASE_CMD
  end

if flags.delete("--msconvert-usage")
  reply = `#{msconvert_command}`
  puts reply 
  exit
end

$MULTITHREAD = false if flags.delete("--no-multithread")

if $MULTITHREAD
  puts "using a #{CORES_TO_USE} count thread-pool"
  pool = Babypool.new(:thread_count => CORES_TO_USE)
end

cmd_reply = {}
files.each do |file|
  final_opts = 
    if has_outdir || using_filelist
      options
    else
      options + ['-o', File.dirname(file)]
    end
  cmd = [msconvert_command, file, *(final_opts + flags)].join(" ")
  if $MULTITHREAD
    puts "pushing #{file} onto the multithread queue"
    pool.work(cmd) do |_cmd|
      reply = `#{_cmd}`
      cmd_reply[_cmd] = reply
    end
  else
    puts "working on: #{file}"
    reply = `#{cmd}` 
    cmd_reply[cmd] = reply
  end
end

pool.drain if $MULTITHREAD

cmd_reply.each do |cmd,reply|
  puts "executed: #{cmd}"
  puts reply
end

