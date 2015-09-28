module Gamefic::Attachable
  attr_writer :attached
  def parent=(p)
    @attached = false
    super
  end
  def attached?
    @attached ||= false
  end
end
