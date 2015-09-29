import 'standard/entities/portal'

class Gamefic::Door < Gamefic::Portal
  include Openable
  include Lockable
  
  serialize :open?, :locked?, :lock_key, :automatic?
  
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
  def automatic=(bool)
    @automatic = bool
    rev = find_reverse
    if !rev.nil? and rev.automatic? != bool
      rev.automatic = bool
    end
  end
  # HACK Even though Door includes Lockable, we need
  # to add the lock_key definitions here for Opal.
  def lock_key
    @lock_key
  end
  def lock_key=(entity)
    @lock_key = entity
    rev = find_reverse
    if !rev.nil? and rev.lock_key != entity
      rev.lock_key = entity
    end
  end
  def automatic?
    @automatic ||= true
  end
end
