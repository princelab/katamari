#!/usr/bin/env ruby

CLIENT_BIN = "msconvert_client.rb"
executable = CLIENT_BIN


if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} [OPTIONS] <file>.raw ..."
  puts "output: <file>.mzML ..."
  puts "options:"
  puts "      --msconvert-help     show msconvert usage and exit"
  puts ""
  puts "*** passes through ALL msconvert options ***"
  puts "avoid these opts (unecessary): -f/--filelist and -e/--ext"
  exit
end

if ARGV.include?("--msconvert-help")
 puts(`#{executable} --help`)
 exit
end

unless (ARGV.include?("-z") || ARGV.include?("--zlib"))
  STDERR.puts "are you sure you don't want binary data compression? (hint: '-z')"
end

(args, files) = ARGV.partition {|v| v[/^-/] }

files.each do |file|
  print `#{executable} #{file} #{args.join(' ')}`
end
