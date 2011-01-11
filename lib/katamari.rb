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

  # This method generates all necessary downstream files (or uses existing
  # ones unless overwrite==true).  A file in list_of_files may be relative,
  # extensionless, or a full path with extension (or some combo).
  # a parallel array to search_engines is returned where each entry is an
  # array of the desired files.  Each search engine must respond_to
  # :search_input_extension
  def generate_downstream_files(search_engines, list_of_files, overwrite=false)
    wanted = search_engines.map do |se|
      se.search_input_extension
    end
    wanted.each do |ext|
      #####
    end
 end

end
