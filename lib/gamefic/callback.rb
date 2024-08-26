# frozen_string_literal: true

module Gamefic
  class Callback
    # @param narrative [Narrative]
    # @param code [Proc]
    def initialize narrative, code
      @narrative = narrative
      @code = code
    end

    def run *args
      Stage.run @narrative, *args, &@code
    end
  end
end
