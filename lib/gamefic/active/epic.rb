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

      def syntaxes
        rulebooks.flat_map(&:syntaxes)
      end

      # @return [Array<Response>]
      def responses_for(*verbs)
        rulebooks.to_a
                 .reverse
                 .flat_map { |rb| rb.responses_for(*verbs) }
      end

      # @param name [Class<Scene::Default>, Symbol]
      # @return [Scene]
      def select_scene class_or_name
        if class_or_name.is_a?(Class)
          instantiate_scene class_or_name
        else
          select_scene_by_symbol class_or_name
        end
      end

      private

      def instantiate_scene klass
        klass.new(nil, narratives.first)
      end

      def select_scene_by_symbol name
        scenes = rulebooks.map { |rlbk| rlbk.scenes[name] }
                          .compact
        raise ArgumentError, "Scene named `#{name}` does not exist" if scenes.empty?

        logger.warn "Found #{scenes.length} scenes named `#{name}`" unless scenes.one?

        scenes.last
      end
    end
  end
end
