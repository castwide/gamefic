class String
  include Gamefic::Matchable
  # Capitalize the first letter without changing the rest of the string.
  # (String#capitalize makes the rest of the string lower-case.)
  def capitalize_first
    "#{self[0,1].upcase}#{self[1,self.length]}"
  end
  # @return [String]
  def cap_first
    self.capitalize_first
  end
  # @return [Array]
  def split_words
    self.gsub(/ +/, ' ').strip.split
  end
end
