module Gamefic
  module Scriptable
    module Subplots
      # The hash of data that was used to initialize the subplot.
      #
      # @return [Hash]
      attr_reader :config

      # The host plot.
      #
      # @return [Plot]
      attr_reader :plot

      # Remove an actor from the subplot with an optional cue
      #
      # @param actor [Gamefic::Actor]
      # @next_cue [Symbol, nil]
      def exeunt actor, next_cue = nil
        super(actor)
        actor.cue next_cue if next_cue
      end

      def conclude
        scenebook.run_conclude_blocks
        players.each { |p| exeunt p }
        entities.each { |e| destroy e }
      end
  
      # @return [Subplot]
      def subplot
        self
      end
    end
  end
end
