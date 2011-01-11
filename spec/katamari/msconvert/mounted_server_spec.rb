require 'spec_helper'

require 'katamari/msconvert/mounted_server'

describe 'checking arguments' do
  it 'can classify arguments' do
    args = "file1 file2 --opt1=val1 -opt2=val2 --opt3 val3 -o val4 --flag -f -v".split(/\s+/)

    # here, we don't specify any specific args
    (arguments, options, flags) = Katamari::Msconvert::MountedServer.classify_arguments(args)
    arguments.enums ["file1", "file2", "val3", "val4"]
    options.is []
    flags.enums ["--opt1=val1", "-opt2=val2", "--opt3", "-o", "--flag", "-f", "-v"]

    flags_with_vals = %w(--opt1 -opt2 --opt3 -o)
    (arguments, options, flags) = Katamari::Msconvert::MountedServer.classify_arguments(args, flags_with_vals)
    arguments.enums ["file1", "file2"]
    options.enums [["--opt1", "val1"], ["-opt2", "val2"], ["--opt3", "val3"], ["-o", "val4"]]
    flags.enums ["--flag", "-f", "-v"]
  end
end
