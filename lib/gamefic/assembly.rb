module Gamefic
  # A base class for managing the resources that compose plots and subplots.
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
      run_scripts
      setup.entities.hydrate
      setup.scenes.hydrate
      setup.actions.hydrate
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

    def run_scripts
      self.class.blocks.each { |blk| stage(&blk) }
    end

    def setup
      @setup ||= Setup.new
    end
  end
end
