# frozen_string_literal: true

module Gamefic
  # A safe execution environment for narrative code.
  #
  module Stage
    module_function

    # @param narrative [Narrative]
    def run(narrative, &code)
      container = narrative.clone
      narrative.instance_exec(&code).tap { validate_changes narrative, container, code }
    end

    OVERWRITEABLE_CLASSES = [String, Numeric, Symbol].freeze

    SWAPPABLE_VALUES = [true, false, nil].freeze

    class << self
      private

      def validate_changes narrative, container, code
        container.instance_variables.each do |var|
          next unless narrative.instance_variables.include?(var)

          cval = container.instance_variable_get(var)

          nval = narrative.instance_variable_get(var)
          next if cval == nval

          validate_overwriteable(cval, nval, "Illegal reassignment of #{var} in #{code}")
        end
      end

      def validate_overwriteable cval, nval, error
        raise error unless overwriteable?(cval, nval)
      end

      def overwriteable? cval, nval
        return true if swappable?(cval, nval)

        allowed = OVERWRITEABLE_CLASSES.find { |klass| cval.is_a?(klass) }
        allowed && cval.is_a?(allowed)
      end

      def swappable? *values
        values.all? { |val| SWAPPABLE_VALUES.include?(val) }
      end
    end
  end
end
