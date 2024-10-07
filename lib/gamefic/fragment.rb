# frozen_string_literal: true

module Gamefic
  # Fragments are standalone clips that can be executed from game events.
  #
  # Authors should subclass Fragment and override the `run` method.
  #
  # @example
  #   class HelloWorld < Gamefic::Fragment
  #    def run
  #      actor.tell 'Hello, world!'
  #    end
  #   end
  #
  #   class MyPlot < Gamefic::Plot
  #     respond :hello do |actor|
  #       HelloWorld.run actor
  #     end
  #   end
  #
  class Fragment
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
