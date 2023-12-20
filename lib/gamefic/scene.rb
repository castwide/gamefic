# frozen_string_literal: true

require 'gamefic/props'
require 'gamefic/rig'

module Gamefic
  # A Scene provides blocks to be executed at the start and finish of a turn.
  # Plots execute Scenes by creating Takes.
  #
  class Scene
    # @return [Class<Rig::Default>]
    attr_reader :rig

    # @return [Symbol]
    attr_reader :name

    def run_start_blocks actor, props
      @start_blocks.each { |blk| @stage.call(actor, props, &blk) }
    end

    def run_finish_blocks actor, props
      @finish_blocks.each { |blk| @stage.call(actor, props, &blk) }
    end

    # @param name [Symbol]
    # @param rig [Class<Rig::Default>]
    # @param type [String, nil]
    # @param on_start [Proc, nil]
    # @param on_finish [Proc, nil]
    # @yieldparam [self]
    def initialize name, stage, rig: Rig::Default, type: nil, on_start: nil, on_finish: nil, &block
      @name = name
      @stage = stage
      @rig = rig
      @type = type
      @start_blocks = []
      @finish_blocks = []
      @start_blocks.push on_start if on_start
      @finish_blocks.push on_finish if on_finish
      stage.call self, &block if block
    end

    # The type of rig that was used to build the scene.
    #
    # @return [String]
    def type
      @type ||= rig.to_s.split('::').last
    end

    def conclusion?
      rig <= Rig::Conclusion
    end

    # @yieldparam [Actor]
    # @yieldparam [SceneProps::Default]
    def on_start &block
      @start_blocks.push block
    end

    # @yieldparam [Actor]
    # @yieldparam [SceneProps::Default]
    def on_finish &block
      @finish_blocks.push block
    end

    def to_sym
      name
    end
  end
end
