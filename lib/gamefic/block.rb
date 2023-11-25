module Gamefic
  # Blocks of code that narratives execute during initialization (script) and
  # setup (seed).
  #
  class Block
    # @return [Symbol] :script or :seed
    attr_reader :type

    # @return [Proc]
    attr_reader :proc

    # @param type [Symbol] :script or :seed
    # @param proc [Proc]
    def initialize type, proc
      @type = type
      @proc = proc
    end

    def script?
      type == :script
    end

    def seed?
      type == :seed
    end
  end
end
