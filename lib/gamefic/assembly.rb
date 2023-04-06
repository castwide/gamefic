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

    # @return [Playbook]
    attr_reader :playbook

    # @return [Scenebook]
    attr_reader :scenebook

    def initialize
      @playbook = Playbook.new
      @scenebook = Scenebook.new
      run_scripts
      setup.entities.hydrate
      setup.scenes.hydrate
      setup.actions.hydrate
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
