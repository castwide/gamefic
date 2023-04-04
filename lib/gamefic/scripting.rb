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

    private

    def run_scripts
      self.class.blocks.each { |blk| stage &blk }
    end
  end
end
