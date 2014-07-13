module Gamefic

  module CharacterState
  
    class Base
      def initialize *args, &block
        post_initialize *args, &block
      end
      def post_initialize *args, &block
        # Override post_initialize to accept additional arguments.
      end
      def busy?
        @busy ||= false
      end
      def update character
        while (line = character.queue.shift)
          character.state.accept character, line
        end
      end
      def accept character, line
        Director.dispatch(character, line)
      end
      def prompt
        @prompt ||= "> "
      end
    end
    
    class Active < Base
      def post_initialize prompt = "> "
        @prompt = prompt
      end
    end
    
    class Prompted < Base
      def post_initialize prompt, &block
        @prompt = prompt
        @block = block
      end
      def accept character, line
        @block.call character, line
      end
    end

    class Paused < Base
      def post_initialize prompt = "Press enter to continue... ", &block
        @prompt = prompt
        @block = block
      end
      def accept character, line
        character.state = :active
        if @block != nil
          @block.call character
        end
      end
    end
    
    class Concluded < Base
      def post_initialize prompt = "GAME OVER"
        @prompt = prompt
      end
      def accept character, line
        return
      end
    end
    
  end

end
