module Gamefic
  module Scripting
    module Syntaxes
      def syntaxes
        included_scripts.flat_map(&:syntaxes)
      end

      def synonyms
        syntaxes.map(&:synonym).uniq
      end

      private

      def syntax_map
        syntaxes.to_set
                .classify(&:verb)
                .transform_values { |list| list.to_a.sort! { |a, b| a.compare b } }
      end
    end
  end
end
