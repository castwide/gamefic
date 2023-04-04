module Gamefic
  module Plot::Snapshot
    # Save the current game state as an encoded binary.
    # See Gamefic::Plot::Darkroom for more information about
    # the data format.
    #
    # @return [Hash]
    def save
      Gamefic::Plot::Darkroom.new(self).save
    end

    # Restore the game state from a snapshot.
    #
    # @param snapshot [String]
    # @return [void]
    def restore snapshot
      Gamefic::Plot::Darkroom.new(self).restore(snapshot)
    end
  end
end
