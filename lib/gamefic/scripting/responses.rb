module Gamefic
  module Scripting
    module Responses
      def responses
        included_scripts.flat_map(&:responses)
                        .map { |response| response.bind(self) }
      end

      def responses_for *verbs
        # @todo This double reversal is odd, but Gamefic::Standard fails in
        #   Opal without it.
        included_scripts.reverse
                        .flat_map { |script| script.responses_for(*verbs) }
                        .reverse
                        .map { |response| response.bind(self) }
      end
    end
  end
end
