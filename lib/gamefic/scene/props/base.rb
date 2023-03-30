# frozen_string_literal: true

module Gamefic
  module Scene
    module Props
      class Base
        attr_accessor :prompt

        attr_reader :input

        def initialize prompt = '>'
          @prompt = prompt
        end

        def update input:
          @input = input
        end
      end
    end
  end
end
