require 'spec_helper'

require 'katamari/search_engine/xtandem/params'

describe 'reading params file' do
  before do
    @xml_file = TESTFILES + '/xtandem/default_input.xml'
    @xml_file_tmp = TESTFILES + '/xtandem/default_input.xml.tmp'
    @default_params = Katamari::SearchEngine::Xtandem::Params::DEFAULT_PARAMS
  end

  after do
    File.unlink(@xml_file_tmp) if File.exist?(@xml_file_tmp)
  end

  it 'reads the default params file' do
    obj = Katamari::SearchEngine::Xtandem::Params.new(@xml_file)
    obj.config.is @default_params
  end

  it 'can write a default params file from scratch' do
    params = Katamari::SearchEngine::Xtandem::Params.new.default_params!
    params.to_xml(@xml_file_tmp)
    puts @xml_file_tmp
    ok File.stripped_lines_identical?(@xml_file_tmp, @xml_file)
  end
end
