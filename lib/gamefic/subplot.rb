# frozen_string_literal: true

require 'gamefic/plot'
require 'securerandom'

module Gamefic
  # Subplots are disposable plots that run inside a parent plot. They can be
  # started and concluded at any time during the parent plot's runtime.
  #
  # @!method self.script &block
  #   @yieldself [ScriptMethods]
  #
  class Subplot < Narrative
    module ScriptMethods
      include Narrative::ScriptMethods
      include Delegatable::Subplots
    end

    # @!method self.script &block
    #   @see Gamefic::Narrative.script
    #   @yieldself [ScriptMethods]
    delegate ScriptMethods

    # @return [String]
    attr_reader :uuid

    # @param plot [Gamefic::Plot]
    # @param introduce [Gamefic::Actor, Array<Gamefic::Actor>, nil]
    # @param config [Hash]
    def initialize plot, introduce: nil, **config
      @uuid = SecureRandom.uuid
      @plot = plot
      @config = config
      configure
      @config.freeze
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

    def run_scripts
      before = Snapshot.save(@plot)
      super
      after = Snapshot.save(@plot)
      return if before == after

      logger.warn "#{self.class} data changed during script setup. Snapshots may not work properly"
    end

    def inspect
      "#<#{self.class}>"
    end
  end
end
