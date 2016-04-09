class Gamefic::Entity
  attr_accessor :image
  def has_image?
    (@image.to_s != '')
  end
end

class Gamefic::Character
  attr_writer :sees_image
  def sees_image?
    (@sees_image != false)
  end
  def show_image(filename)
    stream "<img src=\"#{filename}\" />";
    @sees_image = true
  end
  def play_sound(filename, loop = false)
    # TODO: Implement
  end
  def play_ambient(filename, loop = false)
    # TODO: Implement
  end
end

assert_action :clear_last_image do |actor, action|
  actor.sees_image = false
  true
end

respond :look, Query::Visible.new() do |actor, subject|
  actor.proceed
  if subject.has_image?
    actor.show_image subject.image
  end
end

on_player_update do |actor|
  if !actor.sees_image? and actor.room.has_image?
    actor.show_image actor.room.image
  end
end
