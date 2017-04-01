module Attachable
  def attached?
    if @attached.nil?
      @attached = false
    end
    @attached
  end
  def attached=(bool)
    @attached = bool
  end
end
