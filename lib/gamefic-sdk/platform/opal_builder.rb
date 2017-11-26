require 'opal'

module Gamefic::Sdk
  module Platform
    module OpalBuilder
      def build_opal_str
        code = %(
require 'opal'
require 'gamefic'
require 'gamefic-sdk/platform/web/engine'
require 'gamefic-sdk/platform/web/user'
module Gamefic
$scripts = {}
        )
        plot.imported_scripts.each do |script|
          code += "$scripts['#{script.path}'] = proc {\n"
          code += script.read
          code += "}\n"
        end
        code += %(
$plot = Gamefic::Plot.new(Gamefic::Source::Text.new($scripts))
$plot.stage do
  def self.const_missing sym
    Gamefic.const_get sym
  end
end
$engine = Gamefic::Engine::Web.new($plot)
$plot.script 'main'
end
        )
        builder = ::Opal::Builder.new
        builder.use_gem 'gamefic'
        builder.use_gem 'gamefic-sdk'
        builder.build_str(code, '(inline)')
        builder.to_s
      end
    end
  end
end
