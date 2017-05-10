module Gamefic
  class Character
    module State
      def state
        @state = {}
        @state.merge! scene.state unless scene.nil?
        @state.merge! output: messages
        @state
      end
    end
  end
end
