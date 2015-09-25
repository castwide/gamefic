module Lockable
  include Openable
  attr_reader :lock_key
  def lockable=(bool)
    @lockable = bool
    openable = true if @lockable
  end
  def lockable?
    @lockable ||= false
  end
  def lock_key=(entity)
    lockable = true
    @lock_key = entity
  end
end
