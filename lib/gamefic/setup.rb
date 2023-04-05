module Gamefic
  # The Setup provides a place to stash entities, scenes, and actions while the
  # initial scripts are running. It's designed to provide a safe, robust way to
  # start, save, and restore plots by separating serializable data (entities)
  # from executable code (scenes and actions).
  #
  class Setup
    # A common container class to store blocks of game code until the plot is
    # ready to hydrate (execute) them. After hydration, subsequent blocks get
    # executed immediately.
    #
    class Box
      def initialize
        @blocks = []
      end

      def prepare &block
        if hydrated?
          block.call
        else
          @blocks.push block
        end
      end

      def hydrate
        @hydrated = true
        @blocks.each(&:call)
        @blocks.clear
      end

      def discard
        @hydrated = true
        @blocks.clear
      end

      def hydrated?
        @hydrated ||= false
      end
    end

    def entities
      @entities ||= Box.new
    end

    def scenes
      @scenes ||= Box.new
    end

    def actions
      @actions ||= Box.new
    end
  end
end
