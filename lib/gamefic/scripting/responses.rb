module Gamefic
  module Scripting
    module Responses
      def responses
        included_scripts.flat_map(&:responses)
                        .concat(self.class.responses)
                        .map { |response| response.bind(self) }
      end

      def responses_for *verbs
        included_scripts.flat_map { |script| script.responses_for(*verbs) }
                        .concat(self.class.responses_for(*verbs))
                        .map { |response| response.bind(self) }
      end

      def syntaxes
        @syntaxes ||= self.class
                          .included_scripts
                          .flat_map(&:syntaxes)
                          .concat(self.class.syntaxes)
      end

      def syntaxes_for *synonyms
        synonyms.flat_map { |syn| syntax_map.fetch(syn, []) }
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
