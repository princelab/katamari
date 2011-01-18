require 'pathname'
require 'socket'
require 'fileutils'

require 'katamari/msconvert/mounted_server/mount_mapper'
require 'katamari/msconvert/mounted_server/server'
require 'katamari/msconvert/mounted_server/client'

class Katamari
  # provides a simple TCP server/client architecture for converting files
  # depends on a computer running msconvert_server.rb (found in bin dir)
  class Msconvert
    # contains classes and methods to implement a TCP server/client
    # architecture for using msconvert from pwiz where the server and
    # client both have access to some shared file space.  The client specifies
    # the relative location of the file and msconvert options and the server
    # runs the command and returns any output.
    module MountedServer
      DEFAULT_PORT = 22907  # arbitrary
      MSCONVERT_CMD_WIN = "msconvert.exe"
      # temporary directory under the server mount directory
      DEFAULT_MOUNT_TMP_SUBDIR = "tmp"
      CUE_FOR_HELP = "--help"

      def wrap_reply(st)
        "<reply>\n#{st}\n</reply>"
      end


      # takes the argument string and determines what the output file
      # extension will be.
      def expected_extension(args)
        if md = args.match(/(-e|--ext)\s+(\w+)/)
          md[2]
        elsif args["--mzXML"]
          ".mzXML"
        elsif args["--mgf"]
          ".mgf"
        elsif args["--text"]
          ".txt"
        else ; ".mzML"
        end
      end

      def check_no_spaces(path)
        msg = "\n*********************************************************************\n"
        msg << "msconvert cannot handle spaces in the file path (don't blame me)\n"
        msg << "and you have one or more spaces in your path! (look carefully):\n"
        msg << "#{path}\n"
        msg << "*********************************************************************\n"
        raise ArgumentError, msg if (path && path[" "])
      end

      module_function
      # takes an array of args and returns
      # [arguments, options, flags]
      #
      #     options are   :  --somekey someval
      #     flags are     :  --some-flag
      #     arguments are :  somearg
      #
      # options is returned as an array of pairs.
      # option_keys expects: [--some-key, --outdir, -o]
      # can handle --option=val style but returns it as a option pair: [--option, val]
      def classify_arguments(args, option_keys=[])

        # expand all --opt=val
        exp_args = []
        args.each do |v|
          (a,*b) = v.split("=")
          if option_keys.include?(v)
            exp_args << v
          elsif option_keys.include?(a)
            exp_args << a
            exp_args << b.join("=")
          else
            exp_args << v
          end
        end

        option_indices = (0...(exp_args.size-1)).select {|i| option_keys.include?(exp_args[i]) }

        args_w_vals = option_indices.reverse.map do |i|
          # reverse order keeps things sane
          arg2 = exp_args.delete_at(i+1)
          arg1 = exp_args.delete_at(i)
          [arg1,arg2]
        end.reverse

        (flags, arguments) = exp_args.partition {|v| v[/^-/] }
        [arguments, args_w_vals, flags]
      end

    end
  end
end
