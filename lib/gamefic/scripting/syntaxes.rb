module Gamefic
  module Scripting
    module Syntaxes
      def syntaxes
        included_scripts.flat_map(&:syntaxes)
      end

      def synonyms
        syntaxes.map(&:synonym).uniq
      end
    end
  end
end
