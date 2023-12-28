module Gamefic
  module Delegatable
    module Subplots
      def persist klass, **args
        plot.make klass, *args
      end

      def conclude
        rulebook.events.run_conclude_blocks
        players.each do |plyr|
          rulebook.events.run_player_conclude_blocks plyr
          exeunt plyr
        end
        entities.each { |ent| destroy ent }
      end

      # Start a new subplot based on the provided class.
      #
      # @note A subplot's host is always the base plot, regardless of whether
      #   it was branched from another subplot.
      #
      # @param subplot_class [Class<Gamefic::Subplot>] The Subplot class
      # @param introduce [Gamefic::Actor, Array<Gamefic::Actor>, nil] Players to introduce
      # @param config [Hash] Subplot configuration
      # @return [Gamefic::Subplot]
      def branch subplot_class = Gamefic::Subplot, introduce: nil, **config
        plot.branch subplot_class, introduce: introduce, **config
      end
    end
  end
end
