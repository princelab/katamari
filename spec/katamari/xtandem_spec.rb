require 'spec_helper'

describe 'running X!Tandem' do
  it 'runs a simple example' do
    file = Katamari::XTandem.new(mzMLs, fasta, config).run.mzIdentML
  end
end
