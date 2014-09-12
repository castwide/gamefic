class Entity
  attr_accessor :image
  def has_image?
    (@image.to_s != '')
  end
end

class Character
  def show_image(filename)
    stream "<img src=\"#{filename}\" />";
  end
  def play_sound(filename, loop = false)
    # TODO: Implement
  end
  def play_ambient(filename, loop = false)
    # TODO: Implement
  end
end

assert_action :room_has_image do |actor, action|
  if actor.room.has_image? and actor.room.is?(:lighted)
    actor.show_image actor.room.image
  end
  true
end
