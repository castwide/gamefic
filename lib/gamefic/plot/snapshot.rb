require 'json'

module Gamefic
  module Plot::Snapshot
    # @return [Hash]
    def save
      initial_state
      internal_save
    end

    def restore snapshot
      Gamefic::Plot::Darkroom.new(self).restore(snapshot)
    end

    def initial_state
      if @initial_state.nil?
        @initial_state = internal_save
      end
      @initial_state
    end

    private

    def internal_save
      Gamefic::Plot::Darkroom.new(self).save
    end
  end
end
