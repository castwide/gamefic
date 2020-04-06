require 'json'

module Gamefic
  module Plot::Snapshot
    # Save the current game state as a data hash.
    # See Gamefic::Plot::Darkroom for more information about
    # the data format.
    #
    # @return [Hash]
    def save
      Gamefic::Plot::Darkroom.new(self).save
    end

    # Restore the game state from a snapshot.
    #
    # If `snapshot` is a string, parse it as a JSON object.
    #
    # @note The string conversion is performed as a convenience for web apps.
    #
    # @param snapshot [Hash, String]
    # @return [void]
    def restore snapshot
      snapshot = JSON.parse(snapshot) if snapshot.is_a?(String)
      Gamefic::Plot::Darkroom.new(self).restore(snapshot)
    end
  end
end
