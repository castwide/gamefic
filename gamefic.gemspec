$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
require 'gamefic/version'

Gem::Specification.new do |s|
	s.name        = 'gamefic'
	s.version     = Gamefic::VERSION
	s.date        = Date.today.strftime("%Y-%m-%d")
	s.summary     = "Gamefic"
	s.description = "An adventure game and interactive fiction framework"
	s.authors     = ["Fred Snyder"]
	s.email       = 'fsnyder@gamefic.com'
	s.files       = ['lib/gamefic.rb'] + Dir['lib/gamefic/**/*.rb']
	s.executables << 'gamefic'
	s.homepage    = 'http://gamefic.com'
	s.license     = 'MIT'
	s.required_ruby_version = '>= 2.0.0'
	s.add_runtime_dependency 'slop', '~> 4.0'
	s.add_runtime_dependency 'rubyzip'
	s.add_development_dependency 'rspec'
end
