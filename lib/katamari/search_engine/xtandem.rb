require 'nokogiri'
require 'builder'

class Katamari
  module SearchEngine
    class Xtandem

      include SearchEngine

      def run(file, opts={})
        super(file, opts)
      end

      def create_tandem_input_xml
        #filename,'w') {|out| out.print xml.target! }
      end
    end
  end
end
