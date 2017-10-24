require 'gamefic/grammar'

module Gamefic::Grammar
  module Gender
    MALE =    'male'.freeze
    FEMALE =  'female'.freeze
    OTHER =   'other'.freeze
    NEUTRAL = 'neutral'.freeze

    attr_writer :gender

    # Supported values are "male", "female", "other", and "neutral"
    #
    # @return [String]
    def gender
      @gender ||= "neutral"
    end
  end
end
