module ExplicitExits
  attr_writer :explicit_exits
  def explicit_exits?
    @explicit_exits ||= ExplicitExits.default
  end
  def self.default
    if @default.nil?
      @default = true
    end
    @default
  end
  def self.default=(bool)
    @default = bool
  end
end
