require 'json'

module Gamefic
  module Plot::Snapshot
    # @return [Hash]
    def save
      initial_state
      internal_save
    end

    def restore snapshot
      # HACK Force conclusion of current subplots
      p_subplots.each { |s| s.conclude }
      p_subplots.clear
      Gamefic::Plot::Darkroom.new(self).restore(snapshot)
      entities.each { |e| e.flush }
    end

    def initial_state
      if @initial_state.nil?
        @initial_state = internal_save(false)
      end
      @initial_state
    end

    private

    def internal_save reduce = true
      Gamefic::Plot::Darkroom.new(self).save(reduce: reduce)
    end
  end
end
