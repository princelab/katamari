require 'pathname'
require 'socket'

class Katamari
  # provides a simple TCP server/client architecture for converting files
  # depends on a computer running msconvert_server.rb (found in bin dir)
  class Msconvert

    attr_accessor :server_ip, :port

    # server_ip and port should match those of the computer running
    # msconvert_server.rb
    def initialize(server_ip, port)
      (@server_ip, @port) = server_ip, port
    end

    def usage
      server = TCPSocket.open(@server_ip, @port)
      server.puts("--help")
      reply = server.read
      server.close
      reply
    end

    # if the BASE_DIR on the server is 'S:', then you are only specifying the
    # relative path from there (use unix style slashes)
    #
    #     # file on server is "S:/RAW/tmp/test.raw" with BASE_DIR 'S:'
    #     Katamari::Msconvert.convert("RAW/tmp/test.raw")
    #
    # returns the relative path (from BASE_DIR) to the output file
    def convert(relative_path_on_server, other_args="-z")
      new_ext = other_args["--mzXML"] ? ".mzXML" : ".mzML"
      pn = Pathname.new(relative_path_on_server) 
      outputdir = pn.dirname
      (path, fn) = pn.split

      rel_outfile = File.join(outputdir, fn.sub_ext(new_ext))

      server = TCPSocket.open(@server_ip, @port)

      server.puts relative_path_on_server
      server.puts outputdir
      server.puts other_args

      reply = server.read.chomp
      if reply == "done"
        server.close
      elsif reply == "fail"
        raise "server can't find the outputted file!"
      else
        raise "something bad happened with the conversion! (didn't get confirmation of success...)"
      end
      rel_outfile
    end
  end
end
