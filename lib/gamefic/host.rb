# frozen_string_literal: true

module Gamefic
  # A container for a host narrative (e.g., a subplot's parent plot) that
  # provides safe limited access.
  #
  class Host
    # @param narrative [Narrative]
    def initialize narrative
      @narrative = narrative
    end

    def entities
      @narrative.entities
    end

    def players
      @narrative.players
    end

    def session
      @narrative.session
    end

    def verbs
      @narrative.verbs
    end

    def synonyms
      @narrative.synonyms
    end

    def syntaxes
      @narrative.syntaxes
    end

    def scenes
      @narrative.scenes
    end

    def make(...)
      @narrative.make(...)
    end

    def pick(...)
      @narrative.pick(...)
    end

    def pick!(...)
      @narrative.pick!(...)
    end
  end
end
