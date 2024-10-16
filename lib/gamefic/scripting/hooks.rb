module Gamefic
  module Scripting
    module Hooks
      def before_commands
        find_and_bind(:before_commands)
      end

      def after_commands
        find_and_bind(:after_commands)
      end

      def player_conclude_blocks
        find_and_bind(:player_conclude_blocks)
      end
    end
  end
end
