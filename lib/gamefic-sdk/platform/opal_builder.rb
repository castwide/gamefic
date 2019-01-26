require 'opal'
require 'uglifier'
require 'rubygems'

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
          Gem::Specification.find_all { |spec| spec.name.start_with?('gamefic-') }.each do |spec|
            @opal_builder.use_gem spec.name
          end
          @opal_builder.append_paths config.lib_path
          @opal_builder.build_str(opal_engine_code, '(inline)')
        end
        @opal_builder
      end
    end
  end
end
