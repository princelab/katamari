require 'spec_helper'
require 'katamari'

describe "Katamari" do
  before do
    @config = TESTFILES + "/" + "katamari.yml"
    @sets_file = TESTFILES  + "/" + "sets_config.yml"
  end

  it "runs some searches" do
    kat = Katamari.new(@config)
    ok !kat.nil?
    p kat.run(@sets_file)
  end
end
