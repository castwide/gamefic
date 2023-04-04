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
    include Logging

    # @param block [Proc]
    def stage &block
      theater = Theater.new(self)
      result = theater.instance_eval &block
      logger.warn "Instance variables are not recommended in Gamefic scripts" unless theater.instance_variables.empty?
      result
    end

    def run_scripts
      self.class.blocks.each { |blk| stage &blk }
    end
  end
end
