
require 'yaml'

class Katamari
  class Config < Hash
    def initialize(filename=nil)
      self.default_proc = lambda {|h,k| h[k] = {} }
      if filename
        self.merge!(YAML.load_file(filename))
      end
    end

    # returns [cuts, nocut, c-term?], eg.: ['KR','P',true]
    def enzyme_specificity
      self['search']['enzyme']
    end

    # returns an array of two floats
    def parent_mass_error_distances
      mass_error_as_distance_array(self['search']['spectrum']['parent_mass_error'])[0,2]
    end

    def parent_mass_error_units
      mass_error_as_distance_array(self['search']['spectrum']['parent_mass_error'])[2]
    end

    # returns an array of two floats
    def fragment_mass_error_distances
      mass_error_as_distance_array(self['search']['spectrum']['fragment_mass_error'])[0,2]
    end

    def fragment_mass_error_units
      mass_error_as_distance_array(self['search']['spectrum']['fragment_mass_error'])[2]
    end

    protected
    # returns an array: [distance_down, distance_up, units]
    #
    #     config: -7,+10 ppm  =>  [7,10,ppm]
    #     ## NOTE that the 7 has been negated since it is a distance!
    def mass_error_as_distance_array(string)
      (numbers, units) = string.split(" ")
      (neg,pos) = numbers.split(',').map {|v| Float(v)}
      [-1*neg,pos,units]
    end

    # returns the average width of a mass error string
    def mass_error_width(string)
      (down,up,_) = mass_error_as_array(string)
      (down + up)/2
    end
  end
end
