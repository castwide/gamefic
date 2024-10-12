# frozen_string_literal: true

module Gamefic
  module Active
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

      # @return [Array<Symbol>]
      def verbs
        narratives.flat_map(&:verbs).uniq
      end

      # @return [Array<Symbol>]
      def synonyms
        narratives.flat_map(&:synonyms).uniq
      end

      def empty?
        narratives.empty?
      end

      def one?
        narratives.one?
      end

      def syntaxes
        narratives.flat_map(&:syntaxes)
      end

      # @return [Array<Response>]
      def responses_for(*verbs)
        narratives.to_a
                  .reverse
                  .flat_map { |narr| narr.responses_for(*verbs) }
      end

      # @param name [Class<Scene::Default>, Symbol]
      # @return [Scene]
      def select_scene class_or_name
        return class_or_name if class_or_name.is_a?(Class)

        scenes = narratives.map { |narr| narr.named_scenes[class_or_name] }
                           .compact
        raise ArgumentError, "Scene named `#{class_or_name}` does not exist" if scenes.empty?

        logger.warn "Found #{scenes.length} scenes named `#{class_or_name}`" unless scenes.one?

        scenes.last
      end
    end
  end
end
