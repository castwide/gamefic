module Portable
  attr_writer :portable
  def portable?
    @portable ||= false
  end
end
