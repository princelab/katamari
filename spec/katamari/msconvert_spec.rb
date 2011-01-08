require 'spec_helper'
require 'fileutils'


$HAS_MSCONVERT_SERVER = 
  begin
    server = "192.168.101.185"
    port = 22007
    !TCPSocket.new(server, port).nil?
  rescue Errno::ETIMEDOUT
    false
  end

MOUNT_POINT = "#{ENV["HOME"]/lab}"
NON_MOUNT_DIR = "#{ENV["HOME"]/tmp}"

describe 'converting raw files client/server' do
  if $HAS_MSCONVERT_SERVER
    it 'converts raw files under the mount' do
      FileUtils.cp(TESTFILES + '/test.raw', MOUNT_POINT + '/tmp')       
    end
    it 'converts raw files not under the mount' do
    end
  end
end
