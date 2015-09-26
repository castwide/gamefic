module Itemizable
  attr_writer :itemized
  def itemized?
    if @itemized.nil?
      @itemized = Itemizable.default
    end
    @itemized
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
