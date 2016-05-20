require "gamefic"
include Gamefic

# TODO: These monkey patches might not be a good idea. Look for better
# solutions.

# Use the MetaCharacter class so we can check an array of output for data
# received from tell.
# TODO: It might be better to connect a custom user with a buffered stream.
class MetaCharacter < Character
  def tell(message)
    output.push message
  end
  def output
    @output ||= []
  end
end

# The Entity class is monkey-patched so inspect doesn't puke megs of text into
# the rspec output.
class Entity
  def inspect
    to_s
  end
end
