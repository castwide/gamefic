require 'json'

module Gamefic
  module Plot::Snapshot
    # @return [Hash]
    def save
      Gamefic::Plot::Darkroom.new(self).save
    end

    def restore snapshot
      Gamefic::Plot::Darkroom.new(self).restore(snapshot)
    end
  end
end
