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
            require 'gamefic-opal/engine'
            require 'gamefic-opal/user'
            require '#{config.main}'
            $plot = Gamefic::Plot.new
            $engine = Gamefic::Opal::Engine.new($plot)
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
          # config.libraries.each do |lib|
          #   @opal_builder.use_gem "gamefic-#{lib}" unless lib == 'standard'
          # end
          # @opal_builder.append_paths config.script_path, config.import_path
          @opal_builder.append_paths config.lib_path
          @opal_builder.build_str(opal_engine_code, '(inline)')
        end
        @opal_builder
      end
    end
  end
end
