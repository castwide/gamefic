require 'json'

module Gamefic
  module Plot::Snapshot
    # @return [Hash]
    def save
      initial_state
      internal_save
    end

    def restore snapshot
      snapshot = JSON.parse(snapshot, symbolize_names: true) if snapshot.is_a?(String)
      # HACK: Force conclusion of current subplots
      subplots.each { |s| s.conclude }
      subplots.clear
      Gamefic::Plot::Darkroom.new(self).restore(snapshot)
      entities.each { |e| e.flush }
    end

    def initial_state
      @initial_state ||= internal_save(false)
    end

    private

    def internal_save reduce = true
      Gamefic::Plot::Darkroom.new(self).save(reduce: reduce)
    end
  end
end
