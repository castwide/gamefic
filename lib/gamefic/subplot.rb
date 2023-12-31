# frozen_string_literal: true

require 'gamefic/plot'

module Gamefic
  # Subplots are disposable plots that run inside a parent plot. They can be
  # started and concluded at any time during the parent plot's runtime.
  #
  class Subplot < Narrative
    include Delegatable::Subplots

    # @return [Hash]
    attr_reader :config

    # @return [Plot]
    attr_reader :plot

    # @param plot [Gamefic::Plot]
    # @param introduce [Gamefic::Actor, Array<Gamefic::Actor>, nil]
    # @param config [Hash]
    def initialize plot, introduce: nil, **config
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

    def conclude
      rulebook.run_conclude_blocks
      players.each do |plyr|
        rulebook.run_player_conclude_blocks plyr
        exeunt plyr
      end
      entities.each { |ent| destroy ent }
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

    def inspect
      "#<#{self.class}>"
    end
  end
end
