# frozen_string_literal: true

module Gamefic
  module Scriptable
    module Seeds
      def seeds
        @seeds ||= []
      end

      def seed *methods, &block
        seeds.push(proc { methods.flatten.each { |method| send(method) } }) unless methods.empty?
        seeds.push block if block
      end
    end
  end
end
