require 'spec_helper'

require 'katamari/search_engine/xtandem/params/taxonomy'

describe 'working with a taxonomy.xml file' do
  before do
    @taxonomy_xml_file = TESTFILES + '/xtandem/taxonomy.xml'
    @taxonomy_xml_file_tmp = TESTFILES + '/xtandem/taxonomy.xml.tmp'
    @expected = {
      "yeast"=>["../fasta/scd.fasta.pro", "../fasta/scd_1.fasta.pro", "../fasta/crap.fasta.pro"], 
      "cat"=>["/path/to/some/fasta_file.fasta"]
    }
  end

  after do
    File.unlink(@taxonomy_xml_file_tmp) if File.exist?(@taxonomy_xml_file_tmp)
  end

  it 'reads it' do
    params = Katamari::SearchEngine::Xtandem::Params::Taxonomy.new(@taxonomy_xml_file) 
    params.config.is @expected
  end

  it 'writes it' do
    params = Katamari::SearchEngine::Xtandem::Params::Taxonomy.new
    params.config = @expected
    params.to_xml(@taxonomy_xml_file_tmp)
    abort 'here'
    #ok File.identical?(@taxonomy_xml_file_tmp, @taxonomy_xml_file)
  end
end
