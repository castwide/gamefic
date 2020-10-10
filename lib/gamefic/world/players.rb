module Gamefic
  module World
    module Players
      include Gamefic::World::Entities

      # An array of entities that are currently connected to users.
      #
      # @return [Array<Gamefic::Actor>]
      def players
        @players ||= []
      end

      def player_class cls = nil
        STDERR.puts "Modifying player_class this way is deprecated. Use set_player_class instead" unless cls.nil?
        @player_class = cls unless cls.nil?
        @player_class ||= Gamefic::Actor
      end

      # @param cls [Class]
      def set_player_class cls
        unless cls < Gamefic::Active && cls <= Gamefic::Entity
          raise ArgumentError, "Player class must be an active entity"
        end
        @player_class = cls
      end

      # Make a character that a player will control on introduction.
      #
      # @return [Gamefic::Actor]
      def make_player_character
        cast player_class, name: 'yourself', synonyms: 'self myself you me', proper_named: true
      end
      alias get_player_character make_player_character
    end
  end
end
