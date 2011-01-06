require 'pathname'

class Katamari
  # provides a simple TCP server/client architecture for converting files
  # depends on a computer running msconvert_server.rb (found in bin dir)
  module Msconvert

    # if the BASE_DIR on the server is 'S:', then you are only specifying the
    # relative path from there (use unix style slashes)
    #
    #     # file on server is "S:/RAW/tmp/test.raw" with BASE_DIR 'S:'
    #     Katamari::Msconvert.convert("RAW/tmp/test.raw")
    #
    # returns the relative path (from BASE_DIR) to the output file
    def self.convert(relative_path_on_server, server_ip, other_args="")
      new_ext = 
        if other_args["--mzXML"]
          ".mzXML"
        else
          ".mzML"
        end
      pn = Pathname.new(relative_path_on_server) 
      outputdir = pn.dirname
      (path, fn) = pn.split

      rel_outfile = File.join(outputdir, fn.sub_ext(new_ext))

      port = 22007  # must match that of msconvert_server.rb (in bin dir)
      client = TCPSocket.open(server_ip, port)
      client.puts relative_path_on_server
      client.puts outputdir
      client.puts other_args
      client.close
      rel_outfile
    end
  end
end
