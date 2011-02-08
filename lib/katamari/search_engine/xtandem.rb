require 'nokogiri'
require 'builder'

module Katamari
  module SearchEngine
    class Xtandem

      attr_accessor :config
      def initialize(config)
        @config = config
      end

      def run(mgf_files)
        files.each do |file|
          # create the input file (path to mgf file and output file)
          # run xtandem
        end
      end

      def create_static_input_files
        params = Params.new.default_params!
        # create default params file
        sp = params['spectrum']
        @config['search']
        # create taxonomy file (specifies what species points to what db)
      end
    end
  end
end
