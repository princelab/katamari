#!/usr/bin/env ruby

require 'socket'
require 'katamari/msconvert'

################################################################################
# SETTINGS:
MSCONVERT_CMD = "msconvert.exe"
PORT = 22007
# the mounted directory everything is relative to
BASE_DIR = 'S:'
################################################################################

puts "starting up #{File.basename(__FILE__)} and listening..."
server = TCPServer.open(PORT) # Socket to listen on port 2200
loop do
  client = server.accept
  Katamari::Msconvert.msconvert_server(MSCONVERT_CMD, client, BASE_DIR)
  client.close # Disconnect from the client
end
