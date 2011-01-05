require 'katamari/search_engine/xtandem/params'

class Katamari
  module SearchEngine
    class Xtandem
      class Params

        # holds configuration settings for an X!Tandem taxonomy xml file
        # 
        #     tax_params = Taxonomy.new
        #     cfg = tax_params.config
        #     cfg['dog'] << "file1.fasta"
        #     cfg['dog'] << "file2.fasta" # if multiple fasta files
        #
        #     tax_params.to_xml("taxonomy.xml")  # write taxonomy file
        #
        #     # reads taxonomy xml files
        #     params = Taxonomy.new("taxonomy.xml")
        #     params.config  # => params hash
        class Taxonomy
          BIOML_LABEL = 'x! taxon-to-file matching list'

          attr_accessor :config

          def initialize(xml_file=nil)
            @config = 
              if xml_file ; read_xml(xml_file) 
              else ; Hash.new {|h,k| h[k] = [] }
              end
          end
          
          # returns a hash
          #
          #     hash['yeast'] = ['path/to/fastafile.fasta',...]
          def read_xml(xml_file)
            hash = Hash.new {|h,k| h[k] = [] }
            doc = Nokogiri::XML.parse(IO.read(xml_file), *Params::NOKOGIRI_PARSE_OPTS)
            bioml_n = doc.root
            bioml_n.children.each do |taxon_n|
              taxon_n.children.each do |file_n|
                hash[taxon_n['label']] << file_n['URL']
              end
            end
            hash
          end

          # decides the format type of the fasta file based on its extension:
          # 'peptide' if <file>.pro and 'protein' if <file>.fasta
          # [[is this correct??]]
          # returns 'peptide' if an unrecognized extension
          def file_format(url)
            case File.extname(url)
            when '.pro'
              'peptide'
            when '.fasta'
              'protein'
            else ; 'peptide'
            end
          end

          # if given an output file name, prints to that file
          # always returns the complete xml string
          def to_xml(outfile=nil)
            built = Nokogiri::XML::Builder.new do |xml|
              xml.bioml(:label => BIOML_LABEL) do
                @config.each do |taxon,urls|
                  xml.taxon(:label => taxon) do
                    urls.each do |url|
                      xml.file(:format=>file_format(url), :URL => url)
                    end
                  end
                end
              end
            end
            string = built.to_xml
            File.open(outfile,'w'){|out| out.print string } if outfile
            string
          end
        end
      end
    end
  end
end

