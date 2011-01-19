
module Katamari
  module Util
    module_function
    def to_hash(hash_or_filename)
      if hash_or_filename.is_a?(String) && File.exist?(hash_or_filename)
        YAML.load_file(hash_or_filename)
      else
        hash_or_filename
      end
    end

    # Returns the number of processor for Linux, OS X or Windows.
    # http://blog.robseaman.com/2009/7/11/detecting-the-number-of-processors-with-ruby
    def number_of_processors
      if RUBY_PLATFORM =~ /linux/
        return `cat /proc/cpuinfo | grep processor | wc -l`.to_i
      elsif RUBY_PLATFORM =~ /darwin/
        return `sysctl -n hw.logicalcpu`.to_i
      elsif RUBY_PLATFORM =~ /win32/
        # this works for windows 2000 or greater
        require 'win32ole'
        wmi = WIN32OLE.connect("winmgmts://")
        wmi.ExecQuery("select * from Win32_ComputerSystem").each do |system| 
          begin
            processors = system.NumberOfLogicalProcessors
          rescue
            processors = 0
          end
          return [system.NumberOfProcessors, processors].max
        end
      end
      raise "can't determine 'number_of_processors' for '#{RUBY_PLATFORM}'"
    end

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
