require 'spec_helper'

require 'katamari/convert'

require 'fileutils'

describe 'finding conversion dependencies' do

  before do
    @touch = {
      # can find in same dir
      :mgf_in_base =>  "run1.mgf",
      :mzml_in_base => "run1.mzML",
      :raw_in_base =>  "run1.raw",

      # can find in typefolders from same dir and inside a typefolder
      :a_mgf_tf =>     "sample_a/mgf/run1.mgf",
      :a_mgf_base =>   "sample_a/run1.mgf",
      :a_mzml_tf =>    "sample_a/mzml/run1.mzML",
      :a_raw_tf =>     "sample_a/raw/run1.raw",

      # prefers files in the same directory
      :b_mgf_base =>   "sample_b/run1.mgf",
      :b_raw =>        "sample_b/run1.raw",
      :b_mzml =>       "sample_b/run1.mzML",
      :b_raw_tf =>     "sample_b/raw/run1.raw",
      :b_mzml_tf =>    "sample_b/mzML/run1.mzML",
    ]
    @base_dir = File.expand_path(TESTFILES + "/katamari/convert/tmp")
    @touch_fp = {}
    @touch.each do |key,path|
      FileUtils.mkpath(File.join(@base_dir, File.dirname(path)))
      fn = File.join(@base_dir, path)
      FileUtils.touch(fn)
      @touch_fp[key] = fn
    end
    @cv = Katamari::Convert.new
  end

  after do
    FileUtils.rmtree(@base_dir)
  end

  it 'finds the upstream file in same dir (base)' do 
    reply = @cv.find_upstream(@touch_fp[:mgf_in_base])
    reply.matches %r(#{@touch[:mzml_in_base]})

    reply = @cv.find_upstream(@touch_fp[:mgf_in_base], false)
    reply.matches %r(#{@touch[:raw_in_base]})
  end

  it 'finds the upstream file in filetype dirs' do
    reply = @cv.find_upstream(@touch_fp[:a_mgf_tf])
    reply.matches %r(#{@touch[:a_mzml_tf]})

    reply = @cv.find_upstream(@touch_fp[:a_mgf_tf], false)
    reply.matches %r(#{@touch[5]})
  end
  
end
