
module Katamari
  module Msconvert
    module_function

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

  end
end
