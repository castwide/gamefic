module Darkenable
  attr_writer :dark
  def dark?
    @dark ||= false
  end
end
