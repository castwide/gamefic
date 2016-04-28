script 'media'

module Gamefic::CoverImageViewer
  attr_accessor :cover_image
end

class Gamefic::Character
  include CoverImageViewer
end

on_player_update do |actor|
  if !actor.cover_image.nil?
    actor.stream "<figure class=\"cover\"><img src=\"media/#{actor.cover_image}\" /></figure>"
  end
  actor.cover_image = nil
end

respond :look, Use.room do |actor, room|
  if !room.image.nil?
    actor.cover_image = room.image
  end
  actor.proceed
end

respond :look, Use.reachable do |actor, thing|
  if !thing.image.nil?
    actor.cover_image = thing.image
  end
  actor.proceed
end
