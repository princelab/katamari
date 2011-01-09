require 'spec_helper'
require 'socket'
require 'fileutils'

require 'katamari/msconvert'


# simple mock TCP server that will take as many lines as you tell it to take,
# then spits back whatever you want it to.
class MockMsconvertServer
  def initialize(port)
    @port = port
  end

  def serve(number_lines_to_receive, output, &block)
    server_thread = Thread.new do
      @server = TCPServer.open(@port)
      client = @server.accept
      number_lines_to_receive.times { client.gets.chomp }
      client.puts output
      client.close
    end
    sleep 0.5 # give it time to start the server
    block.call
    #sleep 
    server_thread.join
  end
end

describe 'converting raw files (testing client)' do
  msconvert_usage <<=

  before do
    @ip_address = "127.0.0.1"
    @port = 33424
  end

  it 'gives msconvert usage (from the server)' do
    mock_server = MockMsconvertServer.new(@port)
    mock_server.serve(1, "hiya") do
      reply = Katamari::Msconvert::TCP.new(@ip_address, @port).usage
      ok !reply.nil?
      puts reply
    end
  end

  xit 'converts raw files under the mount' do
    FileUtils.cp(TESTFILES + '/test.raw', '/tmp')       
  end

  xit 'converts raw files not under the mount' do
  end
end
