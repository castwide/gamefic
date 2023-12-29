# frozen_string_literal: true

module Gamefic
  # A collection of narratives.
  #
  class Epic
    # @return [Set<Narrative>]
    attr_reader :narratives

    def initialize
      @narratives = Set.new
    end

    # @param narrative [Narrative]
    def add narrative
      narratives.add narrative
    end

    # @param narrative [Narrative]
    def delete narrative
      narratives.delete narrative
    end

    # @return [Array<Rulebook>]
    def rulebooks
      narratives.map(&:rulebook)
    end

    def empty?
      narratives.empty?
    end

    def conclusion? name
      select_scene(name).conclusion?
    end

    # @return [Scene]
    def select_scene name
      scenes = narratives.map(&:rulebook)
                            .map { |rlbk| rlbk.scenes[name] }
                            .compact
      raise ArgumentError, "Scene named `#{name}` does not exist" if scenes.empty?

      logger.warn "Found #{scenes.length} scenes named `#{name}`" unless scenes.one?

      scenes.last
    end
  end
end
