module Gamefic
  module World
    module Players
      include Gamefic::World::Entities

      # An array of entities that are currently connected to users.
      #
      # @return [Array<Gamefic::Actor>]
      def players
        entities.that_are(Gamefic::Active).reject{|e| e.user.nil?}
      end

      # Connect a user to a character.
      #
      # @param user [Gamefic::User]
      # @param actor [Gamefic::Actor]
      def authorize user, actor
        user.instance_variable_set(:@character, actor)
        actor.instance_variable_set(:@user, user)
      end

      # Set the character that the player will control on introduction.
      #
      # @param actor [Gamefic::Actor]
      def set_player_character actor
        @player_character = actor
      end

      # Get the character that the player will control on introduction.
      #
      # @return [Gamefic::Actor]
      def get_player_character
        @player_character || make_player_character
      end

      private

      def make_player_character
        cast player_class, name: 'yourself', synonyms: 'self myself you me', proper_named: true
      end
    end
  end
end
