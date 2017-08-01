module Gamefic

  module Plot::Players
    # @return [Array<Gamefic::Actor>]
    def players
      p_players.clone
    end

    private

    def p_players
      @p_players ||= []
    end
  end

end
