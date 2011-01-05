require 'builder'

class Katamari
  module SearchEngine
    class Xtandem
      DIR = 'xtandem'
      include SearchEngine

      def run(file, opts={})
        super(file, opts)

      end

      def create_tandem_input
        filename,'w') {|out| out.print xml.target! }
      end

      DEFAULT_PARAMS = {
        'list path' => 

      }

    end
  end
end
