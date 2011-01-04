require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "katamari"
  gem.summary = %Q{mass spectrometry shotgun proteomics analysis pipeline ("clod")}
  gem.description = %Q{katamari ("clod") is a mass spectrometry shotgun proteomics analysis pipeline.  It runs and compiles results from various search engines to identify and quantitate peptides and proteins.}
  gem.email = "jtprince@gmail.com"
  gem.homepage = "http://github.com/jtprince/katamari"
  gem.authors = ["John Prince", "Jesse Jashinsky"]
  gem.add_development_dependency "spec-more", ">= 0"
end
Jeweler::GemcutterTasks.new

Rake::TestTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |spec|
    spec.libs << 'spec'
    spec.pattern = 'spec/**/*_spec.rb'
    spec.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

#task :spec => :check_dependencies

task :default => :spec

Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "katamari #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
