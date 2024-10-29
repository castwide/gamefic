module Gamefic
  module Scripting
    module Seeds
      # @return [Array<Proc>]
      def seeds
        self.class.seeds
      end
    end
  end
end
