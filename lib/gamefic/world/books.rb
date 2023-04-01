module Gamefic
  module World
    module Books
      def playbook
        @playbook ||= Gamefic::Playbook.new
      end

      def scenebook
        @scenebook ||= Gamefic::Scenebook.new
      end
    end
  end
end
