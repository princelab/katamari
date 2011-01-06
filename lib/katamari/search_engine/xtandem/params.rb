require 'nokogiri'

class Katamari
  module SearchEngine
    class Xtandem

      # examples:
      #
      #     # write the default xml file:
      #     Katamari::SearchEngine::Xtandem.Params.new.default_params!.to_xml("default_input.xml")
      #
      #     # read a params file:
      #     params = Katamari::SearchEngine::Xtandem.Params.new("default_input.xml")
      #     # the config hash
      #     cfg = params.config
      #     # the xml: 	<note type="input" label="spectrum, total peaks">50</note> 
      #     cfg['spectrum']['total peaks']  # => '50'
      #     # set values:
      #     cfg['spectrum']['total peaks'] = 0
      #     # note that nil is used to define the top level xml values
      #     # the following corresponds to: 	<note type="input" label="refine">yes</note>
      #     cfg['refine'][nil]  # => 'yes'
      class Params
        NOKOGIRI_PARSE_OPTS = [nil,nil, ::Nokogiri::XML::ParseOptions::DEFAULT_XML | ::Nokogiri::XML::ParseOptions::NOBLANKS]

        DEFAULT_PARAMS = {"list path"=>{"default parameters"=>"default_input.xml", "taxonomy information"=>"taxonomy.xml"}, "spectrum"=>{"fragment monoisotopic mass error"=>"0.4", "parent monoisotopic mass error plus"=>"100", "parent monoisotopic mass error minus"=>"100", "parent monoisotopic mass isotope error"=>"yes", "fragment monoisotopic mass error units"=>"Daltons", "parent monoisotopic mass error units"=>"ppm", "fragment mass type"=>"monoisotopic", "dynamic range"=>"100.0", "total peaks"=>"50", "maximum parent charge"=>"4", "use noise suppression"=>"yes", "minimum parent m+h"=>"500.0", "minimum fragment mz"=>"150.0", "minimum peaks"=>"15", "threads"=>"1", "sequence batch size"=>"1000"}, "residue"=>{"modification mass"=>"57.022@C", "potential modification mass"=>"", "potential modification motif"=>""}, "protein"=>{"taxon"=>"other mammals", "cleavage site"=>"[RK]|{P}", "modified residue mass file"=>"", "cleavage C-terminal mass change"=>"+17.002735", "cleavage N-terminal mass change"=>"+1.007825", "N-terminal residue modification mass"=>"0.0", "C-terminal residue modification mass"=>"0.0", "homolog management"=>"no"}, "refine"=>{nil=>"yes", "modification mass"=>"", "sequence path"=>"", "tic percent"=>"20", "spectrum synthesis"=>"yes", "maximum valid expectation value"=>"0.1", "potential N-terminus modifications"=>"+42.010565@[", "potential C-terminus modifications"=>"", "unanticipated cleavage"=>"yes", "potential modification mass"=>"", "point mutations"=>"no", "use potential modifications for full refinement"=>"no", "potential modification motif"=>""}, "scoring"=>{"minimum ion count"=>"4", "maximum missed cleavage sites"=>"1", "x ions"=>"no", "y ions"=>"yes", "z ions"=>"no", "a ions"=>"no", "b ions"=>"yes", "c ions"=>"no", "cyclic permutation"=>"no", "include reverse"=>"no"}, "output"=>{"log path"=>"", "message"=>"testing 1 2 3", "one sequence copy"=>"no", "sequence path"=>"", "path"=>"output.xml", "sort results by"=>"protein", "path hashing"=>"yes", "xsl path"=>"tandem-style.xsl", "parameters"=>"yes", "performance"=>"yes", "spectra"=>"yes", "histograms"=>"yes", "proteins"=>"yes", "sequences"=>"yes", "results"=>"valid", "maximum valid expectation value"=>"0.1", "histogram column width"=>"30"}}


        # hash holding factored settings
        attr_accessor :config

        def initialize(xml_file=nil)
          @config = 
            if xml_file ; read_xml(xml_file) 
            else ; Hash.new {|h,k| h[k] = {} }
            end
        end

        def convert_mass_error_units(cfg_unit)
          if cfg_unit == 'daltons'
            cfg_unit.capitalize
          else  # ppm is the same
            cfg_unit 
          end
        end

        # returns an array, [cuts, nocut, c-term?], eg:  ['KR','P',true]
        def enzyme_specificity_to_cleavage_site
        end

        # updates the xtandem params from the katamari config file
        def update_from_katamari_config!(cfg)
          
         ################################################################################ 

         working here!!!!!

          # can be either a string or a proc
          srch = cfg['search']
          map = {
            'spectrum' => {
              # not legit??:
               'parent mass type' => srch['parent_mass_type'],
               'fragment mass type' => srch['fragment_mass_type'],
               'parent monoisotopic mass error units' => convert_mass_error_units(cfg.parent_mass_error_units),
               'fragment monoisotopic mass error units' => convert_mass_error_units(cfg.fragment_mass_error_units),
               'fragment monoisotopic mass error' => cfg.mass_error_width(cfg.fragment_mass_error_distances),
          }
          }
          map.each do |maps_from,maps_to|
            if maps_to.is_a?(String)
              @config['spectrum'] [maps_from]


        end


        # sets all params back to default (clearing every other key/val pair)
        # returns self for chaining
        def default_params!
          @config.clear
          @config.merge!(DEFAULT_PARAMS)
          self
        end

        # if given an output file name, prints to that file
        # always returns the complete xml string
        def to_xml(outfile=nil)
          built = Nokogiri::XML::Builder.new do |xml|
            xml.bioml do
              @config.each do |category, subhash|
                subhash.each do |key, val|
                  label = key.nil? ? category : [category,key].join(', ')
                  xml.note(val, :type => "input", :label => label)
                end
              end
            end
          end
          string = built.to_xml
          File.open(outfile,'w'){|out| out.print string } if outfile
          string
        end

        # sets and returns config hash of the xml configuration
        def read_xml(xml_file)
          hash = Hash.new {|h,k| h[k] = {} }
          doc = Nokogiri::XML.parse(IO.read(xml_file), *NOKOGIRI_PARSE_OPTS)
          bioml_node = doc.root
          bioml_node.xpath(".//note[@type='input']").each do |node|
            (category, key) = node['label'].split(/\,\s+/)
            hash[category][key] = node.text
          end
          hash
        end
      end
    end
  end
end

