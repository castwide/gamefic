module Gamefic
  class User::Base
    # @return [Gamefic::Active]
    attr_reader :character

    # @return [Gamefic::Engine::Base]
    attr_reader :engine

    def initialize engine
      @engine = engine
    end

    def connect entity
      @character = entity
    end

    def update state
      raise 'Unimplemented'
    end

    def save filename, snapshot
      raise 'Unimplemented'
    end

    def restore filename
      raise 'Unimplemented'
    end
  end
end
