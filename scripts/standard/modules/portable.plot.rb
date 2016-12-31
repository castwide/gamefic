module Gamefic::Portable
  attr_writer :portable
  attr_writer :sticky
  attr_accessor :sticky_message
  def portable?
    @portable ||= false
  end
  def sticky?
    @sticky ||= false
  end
end
