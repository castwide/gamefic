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
    end
  end
end
