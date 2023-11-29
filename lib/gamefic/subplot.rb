# frozen_string_literal: true

require 'gamefic/plot'
require 'securerandom'

module Gamefic
  # Subplots are disposable plots that run inside a parent plot. They can be
  # started and concluded at any time during the parent plot's runtime.
  #
  class Subplot < Narrative
    module ScriptMethods
      include Narrative::ScriptMethods
      include Scriptable::Subplots
    end

    # @!method self.script &block
    #   @see Gamefic::Narrative.script
    #   @yieldself [ScriptMethods]
    delegate ScriptMethods

    # @return [String]
    attr_reader :uuid

    # @return [Plot]
    attr_reader :plot

    # @return [Host, nil]
    attr_reader :host

    # @return [Hash]
    attr_reader :config

    # @param plot [Gamefic::Plot]
    # @param introduce [Gamefic::Actor, Array<Gamefic::Actor>, nil]
    # @param config [Hash]
    def initialize plot, introduce: nil, **config
      @uuid = SecureRandom.uuid
      @plot = plot
      @host = Host.new(plot)
      @config = config.freeze
      super()
      [introduce].compact.flatten.each { |pl| self.introduce pl }
    end

    def ready
      super
      conclude if concluding?
    end

    # Remove an actor from the subplot with an optional cue
    #
    # @param actor [Gamefic::Actor]
    # @next_cue [Symbol, nil]
    def exeunt actor, next_cue = nil
      super(actor)
      actor.cue next_cue if next_cue
    end

    # Subclasses can override this method to handle additional configuration
    # options.
    #
    def configure; end

    # @see Plot#proxy
    #
    # If the entity is managed on a host and does not need to be proxied,
    # subplots return the original entity instead.
    #
    # @param entity [Entity]
    # @return [Proxy, Entity]
    def proxy entity
      return entity if host.entities.include?(entity)

      super
    end

    def inspect
      "#<#{self.class}>"
    end
  end
end
