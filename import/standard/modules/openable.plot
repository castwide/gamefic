module Openable
  def open
    @closed = false
  end
  def close
    @closed = true
  end
  def open?
    !@closed
  end
  def closed?
    @closed ||= true
  end
end
