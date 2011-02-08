require 'pathname'
require 'socket'
require 'fileutils'

require 'katamari/msconvert/mounted_server/mount_mapper'
require 'katamari/msconvert/mounted_server/server'
require 'katamari/msconvert/mounted_server/client'

module Katamari
  # provides a simple TCP server/client architecture for converting files
  # depends on a computer running msconvert_server.rb (found in bin dir)
  module Msconvert
    # contains classes and methods to implement a TCP server/client
    # architecture for using msconvert from pwiz where the server and
    # client both have access to some shared file space.  The client specifies
    # the relative location of the file and msconvert options and the server
    # runs the command and returns any output.
    module MountedServer
      DEFAULT_PORT = 22907  # arbitrary
      MSCONVERT_CMD_WIN = "msconvert.exe"
      MSCONVERT_CMD_WINE = "wine msconvert.exe"
      # temporary directory under the server mount directory
      DEFAULT_MOUNT_TMP_SUBDIR = "tmp"
      CUE_FOR_HELP = "--help"

      def wrap_reply(st)
        "<reply>\n#{st}\n</reply>"
      end
    end
  end
end
