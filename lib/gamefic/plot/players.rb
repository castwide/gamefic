module Gamefic

  module Plot::Players
    def players
      p_players.clone
    end

    private

    def p_players
      @p_players ||= []
    end
  end

end
