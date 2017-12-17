# @gamefic.script standard/visitor
#   Track rooms that characters have visited. Suppress descriptions for
#   previously visited rooms.

# HACK: Use arrays instead of sets so they can be serialized in snapshots
#require 'set'
script 'standard'

module Visitor
  # @return [Set<Gamefic::Entity>]
  def visits
    @visits ||= []
  end

  # @return [Boolean]
  def visited?(entity)
    visits.include?(entity)
  end
end

class Character
  include Visitor
end

on_player_ready do |player|
  player.visits.push player.room unless player.visited?(player.room)
end

respond :_describe_destination do |actor|
  actor.proceed unless actor.visited?(actor.room)
end
