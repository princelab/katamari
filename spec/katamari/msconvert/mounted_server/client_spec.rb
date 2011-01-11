
require 'spec_helper'
require 'socket'
require 'fileutils'

require 'katamari/msconvert/mounted_server'

# the tests are organized a little wierd but this was how I was able to get a
# mock TCP server working...

# you may need to change this if you want to test local
REAL_SERVER_IP = "192.168.101.185"
EXPECTED_USAGE = IO.read(TESTFILES + '/msconvert/msconvert_usage.txt')

shared "an msconvert client giving usage" do
  it 'gives usage' do
    client = Katamari::Msconvert::MountedServer::Client.new(@ip_address, @port)
    client.usage.is EXPECTED_USAGE
  end
end

shared "an msconvert client getting zipped mzML" do
  it 'works' do
    expected_output_path = @filename.sub(File.extname(@filename), @ext)
    client = Katamari::Msconvert::MountedServer::Client.new(@ip_address, @port)
    ok !File.exist?(expected_output_path)
    output_path, reply = client.convert_on_client(@filename, "-z", @mount_dir)
    output_path.is expected_output_path
    ok File.exist?(output_path)
    IO.read(output_path).matches /zlib compression/m
    reply.matches /writing output file/
  end
end

#shared "an msconvert client creating a zipped mzML file" do
#  it 'works' do
#  end
#end

# simple mock TCP server that will take as many lines as you tell it to take,
# then spits back whatever you want it to.
class MockMsconvertServer
  include Katamari::Msconvert::MountedServer

  def initialize(port, rel_dir=TESTFILES+'/msconvert')
    @port = port
    @rel_dir = rel_dir
  end

  # clean_output is the output without the <reply>OUTPUT</reply> tags
  def open_mock(number_lines_to_receive, clean_output, rel_file=nil, file_contents=nil)
    @server_thread = Thread.new do
      @server = TCPServer.open(@port)
      client = @server.accept
      input_array = number_lines_to_receive.times.map { client.gets.chomp }
      if rel_file
        mm = Katamari::Msconvert::MountedServer::MountMapper.new(@rel_dir)
        FileUtils.mkpath(File.dirname(mm.full_path(rel_file)))
        File.open(mm.full_path(rel_file),'w') {|out| out.print file_contents }
      end
      client.puts wrap_reply(clean_output)
      client.close
      @server.close
    end
    sleep 0.5 # give it time to start the server
  end

  def close
    @server_thread.join
  end
end



describe 'msconvert client + mock server' do
  before do
    @ip_address = "127.0.0.1"
    @port = 33424
    @mock_server = MockMsconvertServer.new(@port)
    @mock_server.open_mock(1, EXPECTED_USAGE)
  end

  after do
    @mock_server.close
  end
  behaves_like "an msconvert client giving usage"
end

describe 'msconvert client + real server' do
  before do
    @ip_address = REAL_SERVER_IP
    @port = Katamari::Msconvert::MountedServer::DEFAULT_PORT
  end
  behaves_like "an msconvert client giving usage"
end



=begin
  xit 'converts raw files under the mount' do
    FileUtils.cp(TESTFILES + '/test.raw', '/tmp')       
  end

  xit 'converts raw files not under the mount' do
  end
=end
