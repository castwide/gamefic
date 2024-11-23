# frozen_string_literal: true

module Gamefic
  class Match
    # @return [Object]
    attr_reader :argument

    # @return [Object]
    attr_reader :token

    # @return [Integer]
    attr_reader :strictness

    # @param argument [Object]
    # @param token [Object]
    # @param strictness [Integer]
    def initialize(argument, token, strictness)
      @argument = argument
      @token = token
      @strictness = strictness
    end
  end
end
