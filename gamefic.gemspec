lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gamefic/version'

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

  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(spec|examples|scripts|html)/|^lib/gamefic-sdk/})
  end
  s.executables   = ['bin/gamefic']
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.1.0'
  s.add_runtime_dependency 'thor'
  s.add_runtime_dependency 'rubyzip'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'codeclimate-test-reporter'
end
