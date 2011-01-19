require 'yaml'
require 'katamari/runner'

module Katamari
  def new
    Katamari::Runner.new
  end
end
