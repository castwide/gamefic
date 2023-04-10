module Gamefic
  module Scriptable
    module Subplots
      # The hash of data that was used to initialize the subplot.
      #
      # @return [Hash]
      attr_reader :config

      # Remove an actor from the subplot with an optional cue
      #
      # @param actor [Gamefic::Actor]
      # @next_cue [Symbol, nil]
      def exeunt actor, next_cue = nil
        super(actor)
        actor.cue next_cue if next_cue
      end
    end
  end
end
