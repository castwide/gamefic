module Gamefic
  module Query
    # @abstract
    module Abstract
      def query subject, token
      end

      def precision
        0
      end
    end
  end
end
