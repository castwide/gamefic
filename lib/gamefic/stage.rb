# frozen_string_literal: true

module Gamefic
  # A safe execution environment for narrative code.
  #
  module Stage
    module_function

    # @param narrative [Narrative]
    # @param extensions [Array<Module>]
    def run(narrative, *extensions, &code)
      contain(narrative, extensions).tap do |container|
        container.instance_exec &code
        # container.stage &code
        merge container, narrative, code
      end
    end

    # @param narrative [Narrative]
    # @param extensions [Array<Module>]
    def contain(narrative, extensions)
      narrative.clone.tap do |container|
        next if extensions.empty?

        container.extend(*extensions)
      end
    end

    OVERWRITEABLE_CLASSES = [String, Numeric, Symbol].freeze

    SWAPPABLE_VALUES = [true, false, nil].freeze

    class << self
      private

      # @param container [Narrative]
      # @param narrative [Narrative]
      def merge container, narrative, code
        container.instance_variables.each do |var|
          cval = container.instance_variable_get(var)
          next if set_new_variable?(narrative, var, cval)

          nval = narrative.instance_variable_get(var)
          next if cval == nval

          raise "#{code} attempted to overwrite #{var}" unless overwriteable?(cval, nval)

          narrative.instance_variable_set(var, cval)
        end
      end

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
        [val1, val2].all? { |val| SWAPPABLE_VALUES.include?(val) }
      end
    end
  end
end
