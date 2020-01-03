require 'json'

module Gamefic
  module Plot::Snapshot
    # @return [Hash]
    def save
      Gamefic::Plot::Darkroom.new(self).save
    end

    def restore snapshot
      snapshot = JSON.parse(snapshot, symbolize_names: false) if snapshot.is_a?(String)
      # HACK: Force conclusion of current subplots
      subplots.each { |s| s.conclude }
      subplots.clear
      Gamefic::Plot::Darkroom.new(self).restore(snapshot)
      entities.each { |e| e.flush }
    end
  end
end
