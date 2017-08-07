module Gamefic
  class User::Base
    # @return [Gamefic::Active]
    attr_reader :character

    # @return [Gamefic::Engine::Base]
    attr_reader :engine

    def initialize engine
      @engine = engine
    end

    # Connect an entity to the user. This method is typically used to identify
    # the player character that a user is controlling. The entity is typically
    # expected to be a subclass of Entity that includes the Active module, an
    # example of which is the Gamefic::Actor class.
    #
    # @param entity [Gamefic::Actor]
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
