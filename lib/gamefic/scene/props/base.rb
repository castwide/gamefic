# frozen_string_literal: true

module Gamefic
  class Scene
    module Props
      class Base
        attr_accessor :prompt

        attr_accessor :input

        def initialize prompt = '>'
          @prompt = prompt
        end
      end
    end
  end
end
