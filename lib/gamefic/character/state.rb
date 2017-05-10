module Gamefic
  class Character
    module State
      def state
        @state ||= {}
        @state.merge! scene.state unless scene.nil?
        @state.merge! output: messages
      end
    end
  end
end
