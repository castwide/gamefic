module Gamefic

  module CharacterState
  
    class Base
      def initialize character, *args, &block
        @character = character
        post_initialize *args, &block
      end
      def post_initialize *args, &block
        # Override post_initialize to accept additional arguments.
      end
      def busy?
        @busy ||= false
      end
      def update
        while (line = @character.queue.shift)
          accept line
          @character.state.update
        end    
      end
      def accept line
        @character.perform line
      end
      def prompt
        @prompt ||= "> "
      end
    end
    
    class Active < Base
      def post_initialize prompt = nil
        @prompt = prompt
      end
    end
    
    class Prompted < Base
      def post_initialize prompt, &block
        @prompt = prompt
        @block = block
      end
      def accept line
        @block.call @character, line
      end
    end

    class Paused < Base
      def post_initialize prompt = nil, &block
        @prompt = prompt || "Press any key to continue... "
        @block = block
      end
      def accept line
        @character.set_state Active
        if @block != nil
          @block.call @character
        end
      end
    end
    
    class Concluded < Base
      def prompt
        @prompt ||= "GAME OVER"
      end
      def accept line
        return
      end
    end
    
  end

end
