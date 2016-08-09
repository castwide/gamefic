module Gamefic::Suggestible
  def suggestions
    @suggestions ||= []
  end
  def suggestions= arr
    @suggestions = arr
  end
  def suggest command
    if !suggestions.include?(command)
      suggestions.push command
    end
  end
  def self.automatic?
    if @automatic.nil?
      @automatic = false
    end
    @automatic
  end
  def self.automatic= bool
    @automatic = bool
  end
end

class Gamefic::Character
  include Suggestible
  serialize :suggestions
end

on_update do
  players.each { |player|
    if Suggestible.automatic? and player.suggestions.length > 0
      player.suggestions.each { |s|
        player.stream "<a class=\"suggestion\" href=\"#\" rel=\"gamefic\" data-command=\"#{s.cap_first}\">#{s.cap_first}</a>"
      }
    end
    #player.suggestions.clear
  }
end

before_player_update do |player|
  player.suggestions.clear
end
