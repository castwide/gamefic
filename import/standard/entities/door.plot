import 'standard/entities/portal'

class Gamefic::Door < Gamefic::Portal
  include Openable
  include Lockable
  attr_reader :key
  def post_initialize
    super
    if @name.nil? and !@direction.nil?
      proper_named = false
      rev = @direction.reverse
      self.name = "the #{@direction.adjective} door"
    end
  end
  def open=(bool)
    super
    rev = find_reverse
    if !rev.nil? and rev.open? != bool
      rev.open = bool
    end
  end
  def locked=(bool)
    super
    rev = find_reverse
    if !rev.nil? and rev.locked? != bool
      rev.locked = bool
    end
  end
end
