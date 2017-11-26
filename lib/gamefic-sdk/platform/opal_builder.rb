require 'opal'
require 'uglifier'

module Gamefic::Sdk
  module Platform
    module OpalBuilder
      def opal_engine_code
        if @opal_engine_code.nil?
          @opal_engine_code = %(
            require 'opal'
            require 'gamefic'
            require 'gamefic-sdk/platform/web/engine'
            require 'gamefic-sdk/platform/web/user'
            module Gamefic
            $scripts = {}
          )
          plot.imported_scripts.each do |script|
            @opal_engine_code += "$scripts['#{script.path}'] = proc {\n"
            @opal_engine_code += script.read
            @opal_engine_code += "}\n"
          end
          @opal_engine_code += %(
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
        end
        @opal_engine_code
      end

      def build_opal_str minify = false
        if minify
          Uglifier.compile(opal_builder.to_s)
        else
          opal_builder.to_s
        end
      end

      def opal_builder
        if @opal_builder.nil?
          @opal_builder = ::Opal::Builder.new
          @opal_builder.use_gem 'gamefic'
          @opal_builder.use_gem 'gamefic-sdk'
          @opal_builder.build_str(opal_engine_code, '(inline)')
        end
        @opal_builder
      end
    end
  end
end
