class Entity
  attr_accessor :image
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
