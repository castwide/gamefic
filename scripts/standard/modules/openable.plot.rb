module Openable
  attr_writer :openable
  def open= bool
    @open = bool
  end
  def open?
    @open ||= false
  end
  def closed?
    !open?
  end
  def accessible?
    open?
  end
end
