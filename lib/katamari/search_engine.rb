

class Katamari
  module SearchEngine
  end
end

%w(xtandem).each {|engine| require "katamari/search_engine/#{engine}" }
