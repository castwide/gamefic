require 'gamefic/grammar'

module Gamefic::Grammar
  module Gender
    attr_writer :gender

    # Supported values are "male", "female", "other", and "neutral"
    #
    # @return [String]
    def gender
      @gender ||= "neutral"
    end
  end
end
