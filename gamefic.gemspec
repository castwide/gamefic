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
  s.homepage      = 'https://gamefic.com'
  s.license       = 'MIT'

  s.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.7.0'

  s.add_runtime_dependency 'base64', '~> 0.1'
  s.add_runtime_dependency 'yard-solargraph', '~> 0.1'

  s.add_development_dependency 'opal', '~> 1.7'
  s.add_development_dependency 'opal-rspec', '~> 1.0'
  s.add_development_dependency 'opal-sprockets', '~> 1.0'
  s.add_development_dependency 'rake', '~> 13.2'
  s.add_development_dependency 'rspec', '~> 3.5', '>= 3.5.0'
  s.add_development_dependency 'simplecov', '~> 0.14'
end
