module Gamefic
  class Engine
    def initialize(plot: Gamefic::Plot.new)
      @plot = plot
    end

    # @return [Gamefic::Active]
    def connect user, character: nil
      character ||= begin
        fresh = plot.get_player_character
        plot.introduce fresh
        fresh
      end
      user_char[user] = character
    end

    def disconnect user
      return unless user_char.key?(user)
      user_char[user].queue.clear
      user_char.delete user
    end

    def turn
      plot.ready
      update_users
      plot.update
    end

    private

    # @return [Gamefic::Plot]
    attr_reader :plot

    def user_char
      @user_char ||= {}
    end

    def update_users
      user_char.each_pair do |user, char|
        user.update char.state
        next if char.concluded?
        input = user.query
        next if input.nil?
        char.queue.push input
      end
    end
  end
end
