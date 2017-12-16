module Gamefic
  class User::Base
    # @return [Gamefic::Actor]
    attr_reader :character

    # @return [Gamefic::Engine::Base]
    attr_reader :engine

    def initialize engine
      @engine = engine
    end

    def update state
      puts character.state.to_json
    end

    def save filename, snapshot
      raise 'Unimplemented'
    end

    def restore filename
      raise 'Unimplemented'
    end
  end
end
