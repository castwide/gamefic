lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gamefic-tty/version'
require 'date'

Gem::Specification.new do |s|
  s.name          = 'gamefic-tty'
  s.version       = Gamefic::Tty::VERSION
  s.date          = Date.today.strftime("%Y-%m-%d")
  s.summary       = "Gamefic"
  s.description   = "Libraries for running terminal-based Gamefic apps"
  s.authors       = ["Fred Snyder"]
  s.email         = 'fsnyder@gamefic.com'
  s.homepage      = 'http://gamefic.com'
  s.license       = 'MIT'

  s.files = ['lib/gamefic-tty.rb'] + Dir['lib/gamefic-tty/**/*.rb']
  s.executables   = ['gamefic']
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.1.0'
  s.add_runtime_dependency 'gamefic-core', '~> 2.0'

  s.add_development_dependency 'rspec', '~> 3.5', '>= 3.5.0'
  s.add_development_dependency 'rake', '~> 11.3', '>= 11.3.0'
end
