#!/usr/bin/env ruby

require 'socket'
require 'katamari/msconvert'

################################################################################
# SETTINGS:

### Will probably need to change for your system:
# the mounted directory everything is relative to
BASE_DIR = 'S:'

### Probaby don't need to change:
# change if you need to specify a full path or different name
MSCONVERT_CMD = Katamari::Msconvert::TCP::MSCONVERT_CMD_WIN
# you can change this if you like, just make sure the client knows
PORT = Katamari::Msconvert::TCP::DEFAULT_PORT
################################################################################

puts "starting up #{File.basename(__FILE__)} and listening..."
server = TCPServer.open(Katamari::Msconvert::TCP::DEFAULT_PORT) # Socket to listen on port 2200

loop do
  client = server.accept
  Katamari::Msconvert::TCP.msconvert_server(MSCONVERT_CMD, client, BASE_DIR)
  client.close # Disconnect from the client
end
