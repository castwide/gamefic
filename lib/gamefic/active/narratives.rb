# frozen_string_literal: true

module Gamefic
  module Active
    # A narrative container for active entities.
    #
    class Narratives
      include Enumerable

      # @param narrative [Narrative]
      def add(narrative)
        narrative_set.add(narrative)
      end

      # @param narrative [Narrative]
      def delete(narrative)
        narrative_set.delete(narrative)
      end

      def empty?
        narrative_set.empty?
      end

      # @return [Integer]
      def length
        narrative_set.length
      end

      def one?
        narrative_set.one?
      end

      # @return [Array<Response>]
      def responses
        narrative_set.flat_map(&:responses)
      end

      # @return [Array<Response>]
      def responses_for(*verbs)
        narrative_set.flat_map { |narr| narr.responses_for(*verbs) }
      end

      # @return [Array<Syntax>]
      def syntaxes
        narrative_set.flat_map(&:syntaxes)
      end

      def syntaxes_for(*synonyms)
        narrative_set.flat_map { |narr| narr.synonyms_for(*synonyms) }
      end

      # True if the specified verb is understood by any of the narratives.
      #
      # @param verb [String, Symbol]
      def understand?(verb)
        narrative_set.flat_map(&:synonyms).include?(verb.to_sym)
      end

      # @return [Array<Binding>]
      def before_commands
        narrative_set.flat_map(&:before_commands)
      end

      # @return [Array<Binding>]
      def after_commands
        narrative_set.flat_map(&:after_commands)
      end

      def each(&block)
        narrative_set.each(&block)
      end

      # @return [Array<Narrative>]
      def that_are(*args)
        narrative_set.to_a.that_are(*args)
      end

      # @return [Array<Narrative>]
      def that_are_not(*args)
        narrative_set.to_a.that_are_not(*args)
      end

      # @return [Array<Entity>]
      def entities
        narrative_set.flat_map(&:entities)
      end

      # @return [Array<Binding>]
      def player_output_blocks
        narrative_set.flat_map(&:player_output_blocks).uniq(&:code)
      end

      private

      # @return [Set<Narrative>]
      def narrative_set
        @narrative_set ||= Set.new
      end
    end
  end
end
