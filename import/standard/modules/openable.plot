module Openable
  attr_writer :open
  def open?
    @open ||= false
  end
  def closed?
    !open?
  end
end
