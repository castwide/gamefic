module Gamefic
  module World
    module Players
      include Gamefic::World::Entities

      # An array of entities that are currently connected to users.
      #
      # @return [Array<Gamefic::Actor>]
      def players
        p_players
      end

      # Get the character that the player will control on introduction.
      #
      # @return [Gamefic::Actor]
      def get_player_character
        cast player_class, name: 'yourself', synonyms: 'self myself you me', proper_named: true
      end
    end
  end
end
