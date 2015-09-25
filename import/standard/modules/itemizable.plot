module Itemizable
  attr_writer :itemized
  def itemized?
    @itemized ||= true
  end
end
