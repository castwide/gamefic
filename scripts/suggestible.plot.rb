class Gamefic::Suggestions
  def current
    @current ||= []
  end

  def future
    @future ||= []
  end

  def update
    current.clear
    current.concat future
    future.clear
  end

  def clear
    current.clear
    future.clear
  end
end

module Gamefic::Suggestible
  def suggestions
    @suggestions ||= Gamefic::Suggestions.new
  end

  def suggest command
    suggestions.future.push command unless suggestions.future.include? command
  end

  def state
    super.merge(suggestions: suggestions.current.map{|s| s.cap_first})
  end
end

class Gamefic::Character
  include Suggestible
end

on_player_ready do |player|
  if player.scene == default_scene or player.next_scene == default_scene
    player.suggestions.update
  else
    player.suggestions.clear
  end
end

respond :suggest do |actor|
  actor.stream '<ul>'
  actor.suggestions.current.sort.each { |s|
    actor.stream "<li>#{s}</li>"
  }
  actor.stream '</ul>'
end
