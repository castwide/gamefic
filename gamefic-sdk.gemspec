lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gamefic-sdk/version'
require 'date'

Gem::Specification.new do |s|
  s.name          = 'gamefic-sdk'
  s.version       = Gamefic::Sdk::VERSION
  s.date          = Date.today.strftime("%Y-%m-%d")
  s.summary       = "Gamefic SDK"
  s.description   = "Development tools for Gamefic"
  s.authors       = ["Fred Snyder"]
  s.email         = 'fsnyder@gamefic.com'
  s.homepage      = 'http://gamefic.com'
  s.license       = 'MIT'

  s.files = ['lib/gamefic-sdk.rb'] + Dir['lib/gamefic-sdk/**/*.rb'] + Dir['html/**/*'] + Dir['scripts/**/*']
  s.executables   = ['gfk']
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.1.0'
  s.add_runtime_dependency 'gamefic', '~> 1.5'
  s.add_runtime_dependency 'opal', '~> 0.10', '>= 0.10.3'
  s.add_runtime_dependency 'uglifier', '~> 3.2'
  s.add_runtime_dependency 'sinatra', '~> 1.4'

  s.add_development_dependency 'rspec', '~> 3.5', '>= 3.5.0'
  s.add_development_dependency 'capybara', '~> 2.0', '>= 2.0'
  s.add_development_dependency 'selenium-webdriver', '~> 3.4'
end
