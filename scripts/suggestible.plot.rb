class Gamefic::Suggestions
  def current
    @current ||= []
  end

  def previous
    @previous ||= []
  end

  def update
    previous.clear
    previous.concat current
    current.clear
  end

  def clear
    previous.clear
    current.clear
  end
end

module Gamefic::Suggestible
  def suggestions
    @suggestions ||= Gamefic::Suggestions.new
  end

  def suggest command
    suggestions.current.push command unless suggestions.current.include? command
  end

  def state
    super.merge(suggestions: suggestions.current.map{|s| s.cap_first})
  end
end

class Gamefic::Character
  include Suggestible
end

before_player_update do |player|
  if player.scene == default_scene or player.next_scene == default_scene
    player.suggestions.update
  else
    player.suggestions.clear
  end
end

respond :suggest do |actor|
  actor.stream '<ul>'
  actor.suggestions.previous.sort.each { |s|
    actor.stream "<li>#{s}</li>"
  }
  actor.stream '</ul>'
end
