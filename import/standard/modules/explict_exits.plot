module ExplicitExits
  attr_writer :explicit_exits
  def explicit_exits?
    @explicit_exits ||= true
  end
end
