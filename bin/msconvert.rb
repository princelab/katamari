#!/usr/bin/env ruby


def has_program?(program)
  ENV['PATH'].split(File::PATH_SEPARATOR).any? do |directory|
    File.executable?(File.join(directory, program.to_s))
  end
end

CLIENT_BIN = "msconvert_client.rb"

executable = 
  if has_program?(CLIENT_BIN)
    CLIENT_BIN
  else
    File.join(File.dirname(File.expand_path(__FILE__)), CLIENT_BIN)
  end


if ARGV.size == 0
  puts executable
  reply = `#{executable} --help`
  puts reply
  exit
end

(args, files) = ARGV.partition {|v| v[/^-/] }

files.each do |file|
  print `#{executable} #{file} #{args.join(' ')}`
end
