require 'rubygems'
require 'spec/more'

Bacon.summary_on_exit

TESTFILES = File.dirname(__FILE__) + '/tfiles'

# returns true if all the lines (after #strip) are identical
# (avoids indentation differences)
def File.stripped_lines_identical?(file1,file2)
  (l1, l2) = [file1,file2].map do |fn|
    IO.readlines(fn).map(&:strip)
  end
  l1 == l2
end
