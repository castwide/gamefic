# frozen_string_literal: true

module Gamefic
  # Clips are runnables that can execute code that involves an actor. They can
  # be useful for reducing the size of callbacks and making features resuable.
  #
  # Authors should subclass `Clip` and override the `run` method.
  #
  # @example
  #   class HelloWorld < Gamefic::Clip
  #    def run
  #      actor.tell 'Hello, world!'
  #    end
  #   end
  #
  #   class MyPlot < Gamefic::Plot
  #     respond :hello do |actor|
  #       actor.run HelloWorld # or `HelloWorld.run actor`
  #     end
  #   end
  #
  class Clip
    # @return [Actor]
    attr_reader :actor

    # @return [Hash]
    attr_reader :config

    # @param actor [Actor]
    def initialize actor, **config
      @actor = actor
      @config = config
      configure
      @config.freeze
    end

    # @return [void]
    def run; end

    # @return [void]
    def configure; end

    def self.run actor, **config
      new(actor, **config).run
    end
  end
end
