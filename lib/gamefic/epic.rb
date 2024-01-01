# frozen_string_literal: true

module Gamefic
  # A collection of narratives.
  #
  class Epic
    include Logging

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

    # @return [Array<Symbol>]
    def verbs
      rulebooks.flat_map(&:verbs).uniq
    end

    # @return [Array<Symbol>]
    def synonyms
      rulebooks.flat_map(&:synonyms).uniq
    end

    def empty?
      narratives.empty?
    end

    def one?
      narratives.one?
    end

    # @param name [Symbol]
    def conclusion? name
      select_scene(name).conclusion?
    end

    # @param name [Symbol]
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
