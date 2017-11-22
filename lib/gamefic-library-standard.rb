require 'gamefic-library'

#module Gamefic::Sdk
#  mount GLOBAL_SCRIPT_PATH
#end

module Gamefic
  module Library
    class Standard < Base
      def post_initialize
        self.path = Gamefic::Sdk::GLOBAL_SCRIPT_PATH
      end
    end
  end
end
