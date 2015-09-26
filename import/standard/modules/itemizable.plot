module Itemizable
  attr_writer :itemized
  def itemized?
    if @itemized.nil?
      @itemized = true
    end
    @itemized
  end
end
