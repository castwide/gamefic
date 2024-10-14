module Gamefic
  module Scripting
    module Seeds
      def seeds
        included_scripts.flat_map(&:seeds)
                        .concat(self.class.seeds)
      end
    end
  end
end
