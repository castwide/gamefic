module Gamefic
  module Scripting
    module Hooks
      # @return [Array<Binding>]
      def before_commands
        find_and_bind(:before_commands)
      end

      # @return [Array<Binding>]
      def after_commands
        find_and_bind(:after_commands)
      end

      # @return [Array<Binding>]
      def ready_blocks
        find_and_bind(:ready_blocks)
      end

      # @return [Array<Binding>]
      def update_blocks
        find_and_bind(:update_blocks)
      end

      # @return [Array<Binding>]
      def player_output_blocks
        find_and_bind(:player_output_blocks)
      end

      # @return [Array<Binding>]
      def conclude_blocks
        find_and_bind(:conclude_blocks)
      end

      # @return [Array<Binding>]
      def player_conclude_blocks
        find_and_bind(:player_conclude_blocks)
      end
    end
  end
end
