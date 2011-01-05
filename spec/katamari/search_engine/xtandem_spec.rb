require 'spec_helper'

require 'katamari/search_engine/xtandem'

describe 'running X!Tandem' do
  it 'runs a simple example' do
    file = Katamari::SearchEngine::XTandem.new(mzMLs, fasta, config).run.mzIdentML
  end
end
