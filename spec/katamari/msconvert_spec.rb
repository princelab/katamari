require 'spec_helper'
require 'socket'
require 'fileutils'

TEST_PORT = 33424
TEST_IP_ADDRESS = "127.0.0.1"

### CREATE 

create a TCP Server and have it spit back what the tester wants to hear (given the right input)


describe 'converting raw files client/server' do
  before do
    TCPSocket.open(PORT)
  end
  if $HAS_MSCONVERT_SERVER
    it 'converts raw files under the mount' do
      FileUtils.cp(TESTFILES + '/test.raw', MOUNT_POINT + '/tmp')       
    end
    it 'converts raw files not under the mount' do
    end
  end
end
