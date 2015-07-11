module Gamefic::Query
  class Matches
    attr_reader :objects, :matching_text, :remainder
    def initialize(objects, matching_text, remainder)
      @objects = objects
      @matching_text = matching_text
      @remainder = remainder
      @@last_match = self
    end
  end
end
