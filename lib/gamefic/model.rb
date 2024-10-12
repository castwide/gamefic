# frozen_string_literal: true

module Gamefic
  # Models provide narrative methods and context to callbacks.
  #
  class Model
    include Scriptable::Proxies

    # @return [Narrative]
    attr_reader :narrative

    # @return [Hash]
    attr_reader :context

    def initialize narrative, _legacy: false, **context
      @narrative = narrative
      @_legacy = _legacy
      @context = unproxy(context)
    end

    def execute *args, &block
      # @todo We might get rid of the stage or move the model functionality
      #   into it
      # Stage.run(narrative, *args, &block)
      @_legacy ? Stage.run(narrative, *args, *block) : instance_exec(*args, &block)
    end

    def method_missing(symbol, ...)
      context.key?(symbol) ? context[symbol] : super
    end

    def respond_to_missing?(symbol, ...)
      context.key?(symbol) || super
    end
  end
end
