module Gamefic
  class User::Base
    # @return [Gamefic::Active]
    attr_reader :character

    def connect entity
      self.character = entity
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
