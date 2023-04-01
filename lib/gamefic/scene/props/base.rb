# frozen_string_literal: true

module Gamefic
  class Scene
    module Props
      class Base
        attr_writer :prompt

        attr_accessor :input

        attr_reader :context

        # @param scene [Scene, nil]
        # @param context [Hash]
        def initialize scene, **context
          @scene = scene
          @context = context
        end

        def prompt
          @prompt ||= '>'
        end

        def output
          @output ||= {
            # scene: {
            #   name: @scene&.name,
            #   type: @scene&.type
            # },
            scene: @scene&.type,
            messages: ''
          }
        end
      end
    end
  end
end
