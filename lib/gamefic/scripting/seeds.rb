module Gamefic
  module Scripting
    module Seeds
      # @return [Array<Proc>]
      def seeds
        (included_scripts.flat_map(&:seeds) + self.class.seeds).uniq
      end
    end
  end
end
