# frozen_string_literal: true

module Gamefic
  class Scene
    module Props
      class Base
        attr_writer :prompt

        attr_accessor :input

        attr_reader :context

        def initialize scene: nil, **context
          @scene = scene
          @context = context
        end

        def [](key)
          context[key]
        end

        def []=(key, value)
          context[key] = value
        end

        def prompt
          @prompt ||= '>'
        end

        def output
          @output ||= {
            scene_name: @scene&.name,
            scene_type: @scene&.type,
            messages: ''
          }
        end
      end
    end
  end
end
