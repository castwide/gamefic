# frozen_string_literal: true

module Gamefic
  # A container for a host narrative (e.g., a subplot's parent plot) that
  # provides safe limited access.
  #
  # @todo Document delegated methods
  #
  class Host
    DELEGATED_METHODS = %i[entities players session verbs synonyms syntaxes scenes make pick pick!].freeze

    # @param narrative [Narrative]
    def initialize narrative
      @narrative = narrative
    end

    if RUBY_ENGINE == 'opal'
      def method_missing symbol, *args
        return @narrative.send(symbol, *args) if DELEGATED_METHODS.include?(symbol)

        super
      end
    else
      def method_missing symbol, *args, **kwargs
        return @narrative.send(symbol, *args, **kwargs) if DELEGATED_METHODS.include?(symbol)

        super
      end
    end

    def respond_to_missing?(symbol, _include_private = false)
      DELEGATED_METHODS.include?(symbol)
    end
  end
end
