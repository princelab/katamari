require 'pathname'

module Katamari
  class Convert
    FILETYPES = [:mgf, :mzml, :raw]

    EXTENSIONS = {
      :mgf => 'mgf',
      :mzml => 'mzML',
      :raw => 'raw',
    }

    CONVERSION_DEP = {
      # x depends on y
      :mgf => [:mzml, :raw],
      :mzml => [:raw],
    }

    #attr_accessor :config
    attr_accessor :overwrite

    def initialize(overwrite=false)
      @overwrite = overwrite
      #@config = Katamari::Util.to_hash(config)
    end

    # returns the filetype symbol
    def filetype(fn)
      File.extname(fn)[1..-1].downcase.to_sym
    end

    # takes the filename and searches for upstream source files, returning the
    # nearest file first.  Does a search for the file by looking in:
    #
    #     1) the directory the file is in (BASE)
    #     2) any filetype directories below BASE
    #        *IF* the file is in a filetype folder also looks in:
    #     3) BASE/../
    #     4) filetype folders in BASE/../
    #
    # if nearest is false, it looks for the furthest upstream file first
    # (nearest upstream is the first file in the value arrays of CONVERSION_DEP)
    def find_upstream(fn, nearest=true)
      base_dir = File.dirname(fn)
      basename_noext = File.basename(fn, '.*')
      dependencies = CONVERSION_DEP[filetype(fn)]
      nearest || (dependencies = dependencies.reverse)
      filename = nil
      dependencies.each do |ft|
        [base_dir, File.join(base_dir,ft.to_s), File.join(base_dir, '..'), File.join(base_dir, '..', ft.to_s)].each do |dir|
          filename = find(dir, basename_noext, ft)
          break if filename
        end
        break if filename
      end
      filename
    end

    def find(dir, basename_noext, ft)
      rec_lc_uc = [EXTENSIONS[ft], ft.to_s, ft.to_s.upcase].uniq
      file = nil
      rec_lc_uc.each do |ext| 
        testing = File.join(dir,basename_noext) << '.' << ext
        break if File.exist?(testing) && file=testing
      end
      file
    end

    def convert_to(file, extension)
      conversions = []
      loop_e = extension
      loop do
        conversions << [CONVERSION_DEP[extension], extension]
        loop_e = CONVERSION_DEP[extension]
      end
    end
  end
end
