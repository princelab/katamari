#!/usr/bin/env ruby

require 'socket'
require 'katamari/msconvert/mounted_server'

################################################################################
# SETTINGS:

### Will probably need to change for your system:
# the mounted directory everything is relative to
BASE_DIR = 'S:'

### Probaby don't need to change:
# change if you need to specify a full path or different name
MSCONVERT_CMD = Katamari::Msconvert::MountedServer::MSCONVERT_CMD_WIN
# you can change this if you like, just make sure the client knows
PORT = Katamari::Msconvert::MountedServer::DEFAULT_PORT
################################################################################

puts "starting up #{File.basename(__FILE__)} and listening..."

server = Katamari::Msconvert::MountedServer::Server.new(MSCONVERT_CMD, PORT, BASE_DIR)
server.run

