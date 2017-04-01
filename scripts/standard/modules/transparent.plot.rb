module Transparent
  attr_writer :transparent
  def transparent?
    @transparent ||= false
  end
end
