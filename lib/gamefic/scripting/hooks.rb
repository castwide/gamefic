module Gamefic
  module Scripting
    module Hooks
      def before_commands
        find_and_bind(:before_commands)
      end

      def after_commands
        find_and_bind(:after_commands)
      end

      def ready_blocks
        find_and_bind(:ready_blocks)
      end

      def update_blocks
        find_and_bind(:update_blocks)
      end

      def player_output_blocks
        find_and_bind(:player_output_blocks)
      end

      def player_conclude_blocks
        find_and_bind(:player_conclude_blocks)
      end
    end
  end
end
