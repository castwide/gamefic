class String
  include Gamefic::Keywords

  # Capitalize the first letter without changing the rest of the string.
  # (String#capitalize makes the rest of the string lower-case.)
  #
  # @return [String] The capitalized text
  def capitalize_first
    "#{self[0, 1].upcase}#{self[1, self.length]}"
  end
  alias cap_first capitalize_first

  # Get an array of words split by any whitespace.
  #
  # @return [Array]
  def split_words
    self.gsub(/[\s]+/, ' ').strip.split
  end
end
