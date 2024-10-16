# frozen_string_literal: true

module Gamefic
  module Active
    class Narratives
      include Enumerable

      def add narrative
        narrative_set.add(narrative)
      end

      def delete narrative
        narrative_set.delete(narrative)
      end

      def empty?
        narrative_set.empty?
      end

      def length
        narrative_set.length
      end

      def one?
        narrative_set.one?
      end

      def responses
        narrative_set.flat_map(&:responses)
      end

      def responses_for(*verbs)
        narrative_set.flat_map { |narr| narr.responses_for(*verbs) }
      end

      def syntaxes
        narrative_set.flat_map(&:syntaxes)
      end

      def syntaxes_for(*synonyms)
        narrative_set.flat_map { |narr| narr.synonyms_for(*synonyms) }
      end

      def before_actions
        narrative_set.flat_map(&:before_actions)
      end

      def after_actions
        narrative_set.flat_map(&:after_actions)
      end

      def before_commands
        narrative_set.flat_map(&:before_commands)
      end

      def after_commands
        narrative_set.flat_map(&:after_commands)
      end

      def each(&block)
        narrative_set.each(&block)
      end

      def that_are(*args)
        narrative_set.to_a.that_are(*args)
      end

      def that_are_not(*args)
        narrative_set.to_a.that_are_not(*args)
      end

      def entities
        narrative_set.flat_map(&:entities)
      end

      private

      def narrative_set
        @narrative_set ||= Set.new
      end
    end
  end
end
