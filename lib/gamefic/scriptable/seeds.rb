# frozen_string_literal: true

module Gamefic
  module Scriptable
    module Seeds
      def seeds
        @seeds ||= []
      end

      def seed &block
        seeds.push block
      end
    end
  end
end
