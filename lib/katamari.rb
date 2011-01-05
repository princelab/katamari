require 'yaml'
require 'katamari/search_engine'

class Katamari
  module Util
    module_function
    def to_hash(hash_or_filename)
      if hash_or_filename.is_a?(String) && File.exist?(hash_or_filename)
        YAML.load_file(hash_or_filename)
      else
        hash_or_filename
      end
    end
  end
  attr_accessor :config
  # takes a filename or hash
  def initialize(config=nil)
    @config = Util.to_hash(config)
  end
  
  # sets can be a filename of a yaml file or a hash
  def run(sets)
    sets = Util.to_hash(sets)
    to_run = config['search'].select {|eng,valhash| valhash['run'] }
    to_run.each do |engine,valhash|
      search_engine = Katamari::SearchEngine.const_get(engine.capitalize).new(@config)
      list_of_runs = sets.map {|key,val| val }.flatten
      search_engine.run(list_of_runs)
    end
  end
end
