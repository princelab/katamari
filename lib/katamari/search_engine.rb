

class Katamari
  module SearchEngine
    def search_input_filetype
      :mgf
    end
  end
end

%w(xtandem).each {|engine| require "katamari/search_engine/#{engine}" }
