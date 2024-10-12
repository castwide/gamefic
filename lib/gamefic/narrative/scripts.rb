module Gamefic
  class Narrative
    module Scripts
      def included_scripts
        self.class
            .included_modules
            .that_are(Scriptable)
      end

      def seeds
        find_and_bind(:seeds)
      end

      def before_actions
        find_and_bind(:before_actions)
      end

      def after_actions
        find_and_bind(:after_actions)
      end

      def player_conclude_blocks
        find_and_bind(:player_conclude_blocks)
      end

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

      def introductions
        included_scripts.flat_map(&:introductions)
                        .concat(self.class.introductions)
      end

      def conclusions
        included_scripts.flat_map(&:introductions)
                        .concat(self.class.introductions)
      end

      def default_scene
        self.class.default_scene
      end

      def default_conclusion
        self.class.default_conclusion
      end

      private

      def syntax_map
        @syntax_map ||= syntaxes.to_set
                                .classify(&:verb)
                                .transform_values { |list| list.sort! { |a, b| a.compare b } }
      end

      def find_and_bind(symbol)
        included_scripts.flat_map { |script| script.send(symbol) }
                        .concat(self.class.send(symbol))
                        .map { |blk| Binding.new(self, blk) }
      end
    end
  end
end
