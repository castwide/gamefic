module Gamefic
  # A base class for managing the scripts that build plots and subplots.
  #
  class Assembly
    class << self
      def blocks
        @blocks ||= []
      end

      def script &block
        blocks.push block
      end
    end

    def initialize
      self.class.blocks.each { |blk| stage &blk }
      setup.entities.hydrate
      setup.scenes.hydrate
      setup.actions.hydrate
      default_scene && default_conclusion # Make sure they exist @todo Necessary?
      playbook.freeze
      scenebook.freeze  
    end

    def playbook
      @playbook ||= Playbook.new
    end

    def scenebook
      @scenebook ||= Scenebook.new
    end

    # @param block [Proc]
    def stage &block
      @theater ||= Theater.new(self)
      @theater.instance_eval &block
    end

    private

    def setup
      @setup ||= Setup.new
    end
  end
end
