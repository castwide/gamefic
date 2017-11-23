require 'gamefic/grammar'

module Gamefic::Grammar
  module Gender
    MALE    = :male
    FEMALE  = :female
    OTHER   = :other
    NEUTRAL = :neutral

    attr_writer :gender

    # Supported values are :male, :female, :other, and :neutral.
    #
    # @return [String]
    def gender
      @gender ||= :neutral
    end
  end
end
