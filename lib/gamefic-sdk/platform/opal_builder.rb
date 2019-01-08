require 'opal'
require 'uglifier'

module Gamefic::Sdk
  module Platform
    module OpalBuilder
      def opal_engine_code
        if @opal_engine_code.nil?
          @opal_engine_code = %(
            require 'opal'
            require 'native'
            require 'gamefic'
            require 'gamefic/query'
            require 'gamefic-opal/plot'
            require 'gamefic-opal/engine'
            require 'gamefic-opal/user'
            $plot = Gamefic::Opal::Plot.new
            $engine = Gamefic::Opal::Engine.new($plot)
          )
          plot.imported_scripts.each do |script|
            @opal_engine_code += %(
              $plot.prepare_script '#{script.path}' do
                #{File.read script.absolute_path}
              end
            )
          end
          @opal_engine_code += "$plot.script 'main'\n"
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
          @opal_builder.append_paths config.script_path, config.import_path
          @opal_builder.build_str(opal_engine_code, '(inline)')
        end
        @opal_builder
      end
    end
  end
end
