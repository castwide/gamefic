require 'gamefic/grammar'

module Gamefic::Grammar
  module Gender
    attr_writer :gender
    def gender
      # Supported values are "male", "female", "neutral", and "none"
      @gender ||= "neutral"
    end
  end
end
