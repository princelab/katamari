require 'spec_helper'

require 'katamari/search_engine/xtandem'

describe 'running X!Tandem' do

  before do
  end

  it 'runs a simple example' do
    xtandem = Katamari::SearchEngine::XTandem.new(fasta, config)
    xtandem.run(mgfs)
  end
end
