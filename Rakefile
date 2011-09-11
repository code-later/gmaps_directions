require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "gmaps_directions"
  gem.homepage = "http://github.com/railsbros_dirk/gmaps_directions"
  gem.license = "MIT"
  gem.summary = %Q{A simple Gem to use the Google Maps distance API from Ruby}
  gem.description = %Q{
    Sometimes you need to calculate the directions between two different points
    via Google Maps on your server-side and not on the client. The Google Maps
    API for that is dead simple and due to this I wrapped calling the API in
    this little gem.
  }
  gem.email = "dirk.breuer@gmail.com"
  gem.authors = ["Dirk Breuer"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
   gem.add_runtime_dependency 'yajl-ruby', '~> 0.8.1'
   gem.add_runtime_dependency 'activesupport', '>= 3.0.4'
   gem.add_development_dependency 'rspec', '~> 2.5.0'
   gem.add_development_dependency 'jeweler', '~> 1.5.2'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "gmaps_directions #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
