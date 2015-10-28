require 'gamefic';module Gamefic;module Gamefic::Portable
  attr_writer :portable
  def portable?
    @portable ||= false
  end
end
;end
