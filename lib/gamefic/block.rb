# frozen_string_literal: true

module Gamefic
  # A code container for seeds and scripts.
  #
  class Block
    # @return [Symbol]
    attr_reader :type

    # @return [Proc]
    attr_reader :code

    # @param type [Symbol]
    # @param code [Proc]
    def initialize type, code
      @type = type
      @code = code
    end

    def script?
      type == :script
    end

    def seed?
      type == :seed
    end
  end
end
