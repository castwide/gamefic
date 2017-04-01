script 'standard/modules/openable'

module Lockable
  include Openable
  attr_reader :lock_key
  def locked=(bool)
    @locked = bool
    if @locked == true
      self.open = false
    end
  end
  def open=(bool)
    @open = bool
    @locked = false if @open == true
  end
  def locked?
    @locked ||= false
  end
  def has_lock_key?
    !@lock_key.nil?
  end
  def lock_key=(entity)
    @lock_key = entity
  end
end
