require 'gamefic/scripting/actions'
require 'gamefic/scripting/scenes'
require 'gamefic/scripting/entities'

module Gamefic
  module Scripting
    module ClassMethods
      def blocks
        @blocks ||= []
      end

      def script &block
        blocks.push block
      end
    end

    include Actions
    include Scenes
    include Entities

    # @param plot [Plot]
    # @param block [Proc]
    def stage &block
      # Scripts can share some information like instance variables before the
      # plot gets instantiated, but running plots should not.
      if initialized?
        @stage = nil
        Theater.new(self).instance_eval &block
      else
        @stage ||= Theater.new(self)
        @stage.tap { |stg| stg.instance_eval(&block) }
      end
    end

    private

    def run_scripts
      self.class.blocks.each { |blk| stage &blk }
    end
  end
end
