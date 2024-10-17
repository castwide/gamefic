# frozen_string_literal: true

module Gamefic
  class Match
    attr_reader :argument
    attr_reader :token
    attr_reader :strictness

    def initialize argument, token, strictness
      @argument = argument
      @token = token
      @strictness = strictness
    end
  end
end
