lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gamefic/version'
require 'date'

Gem::Specification.new do |s|
  s.name          = 'gamefic'
  s.version       = Gamefic::VERSION
  s.date          = Date.today.strftime("%Y-%m-%d")
  s.summary       = "Gamefic"
  s.description   = "An adventure game and interactive fiction framework"
  s.authors       = ["Fred Snyder"]
  s.email         = 'fsnyder@gamefic.com'
  s.homepage      = 'http://gamefic.com'
  s.license       = 'MIT'

  s.files = ['lib/gamefic.rb'] + Dir['lib/gamefic/**/*.rb']
  s.executables   = ['gamefic']
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.1.0'
  s.add_runtime_dependency 'thor', '~> 0.19', '>= 0.19.4'
  s.add_runtime_dependency 'rubyzip', '~> 1.2', '>= 1.2.0'

  s.add_development_dependency 'rspec', '~> 3.5', '>= 3.5.0'
  s.add_development_dependency 'rake', '~> 11.3', '>= 11.3.0'
  s.add_development_dependency 'codeclimate-test-reporter', '~> 1.0', '>= 1.0.0'
end
