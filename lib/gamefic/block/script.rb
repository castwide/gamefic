# frozen_string_literal: true

module Gamefic
  module Block
    class Script < Base
      def execute(narrative)
        contain(narrative, ScriptMethods).tap do |container|
          container.stage &code
          merge container, narrative
        end
      end

      # @param narrative [Narrative]
      # @param extension [Module]
      def contain(narrative, extension)
        narrative.clone
                 .extend(extension)
      end

      def merge container, narrative
        container.instance_variables.each do |var|
          cval = container.instance_variable_get(var)
          next if set_new_variable?(narrative, var, cval)

          nval = narrative.instance_variable_get(var)
          next if cval == nval

          raise "#{code} attempted to overwrite #{var}" unless overwriteable?(cval, nval)

          narrative.instance_variable_set(var, cval)
        end
      end

      OVERWRITEABLE_CLASSES = [String, Numeric, Symbol].freeze

      SWAPPABLE_VALUES = [true, false, nil].freeze

      private

      def set_new_variable? narrative, var, cval
        return false if narrative.instance_variables.include?(var)

        narrative.instance_variable_set(var, cval)
        true
      end

      def overwriteable? cval, nval
        return true if swappable?(cval, nval)

        OVERWRITEABLE_CLASSES.include?(cval.class) && cval.instance_of?(nval.class)
      end

      def swappable? val1, val2
        SWAPPABLE_VALUES.include?(val1) && SWAPPABLE_VALUES.include?(val2)
      end
    end
  end
end
