module Gamefic
  module Scripting
    module Syntaxes
      def syntaxes
        included_scripts.flat_map(&:syntaxes)
                        .concat(self.class.syntaxes)
      end

      def syntaxes_for *synonyms
        synonyms.flat_map { |syn| syntax_map.fetch(syn, []) }
      end

      def synonyms
        syntaxes.map(&:synonym).uniq
      end

      private

      def syntax_map
        @syntax_map ||= syntaxes.to_set
                                .classify(&:verb)
                                .transform_values { |list| list.sort! { |a, b| a.compare b } }
      end
    end
  end
end
