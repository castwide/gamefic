# frozen_string_literal: true

module Gamefic
  # A safe execution environment for narrative code.
  #
  module Stage
    module_function

    # @param narrative [Narrative]
    # @param extensions [Array<Module>]
    def set(narrative, *extensions, &code)
      container = contain(narrative, extensions)
      container.instance_exec(&code).tap { merge container, narrative, code }
    end

    # @param narrative [Narrative]
    def run(narrative, &code)
      container = narrative.clone
      narrative.instance_exec(&code).tap { validate_changes narrative, container }
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

          validate_overwriteable(cval, nval, "#{code} attempted to overwrite #{var}")
          narrative.instance_variable_set(var, cval)
        end
      end

      def set_new_variable? narrative, var, cval
        return false if narrative.instance_variables.include?(var)

        narrative.instance_variable_set(var, cval)
        true
      end

      def validate_overwriteable cval, nval, error
        raise error unless overwriteable?(cval, nval)
      end

      def log_overwriteable cval, nval, error
        Logging.logger.warn error unless overwriteable?(cval, nval)
      end

      def overwriteable? cval, nval
        return true if swappable?(cval, nval)

        allowed = OVERWRITEABLE_CLASSES.find { |klass| cval.is_a?(klass) }
        allowed && cval.is_a?(allowed)
      end

      def swappable? *values
        values.all? { |val| SWAPPABLE_VALUES.include?(val) }
      end

      def validate_changes narrative, container
        container.instance_variables.each do |var|
          cval = container.instance_variable_get(var)
          next if set_new_variable?(narrative, var, cval)

          nval = narrative.instance_variable_get(var)
          next if cval == nval

          log_overwriteable(cval, nval, "#{code} overwrote #{var} in #{narrative}. Snapshots may not restore properly")
        end
      end
    end
  end
end
