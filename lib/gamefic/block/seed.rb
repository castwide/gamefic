# frozen_string_literal: true

module Gamefic
  module Block
    class Seed < Base
      def execute(narrative)
        container = contain(narrative)
        container.stage &code
        merge container, narrative
      end

      private

      def contain(narrative)
        narrative.clone
                 .extend(SeedMethods)
      end

      def merge container, narrative
        container.instance_variables.each do |var|
          val = container.instance_variable_get(var)
          next if val == narrative.instance_variable_get(var)

          raise "#{code} attempted to overwrite #{var}" if narrative.instance_variables.include?(var)

          narrative.instance_variable_set(var, val)
        end
      end
    end
  end
end
