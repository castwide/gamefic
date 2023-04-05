# frozen_string_literal: true

require 'gamefic/props'
require 'gamefic/rig'

module Gamefic
  # A Scene provides blocks to be executed at the start and finish of a turn.
  # Plots execute Scenes by creating Takes.
  #
  class Scene
    # @return [Symbol]
    attr_reader :name

    # @return [Class<Rig::Default>]
    attr_reader :rig

    # @return [Array<Proc>]
    def start_blocks
      @start_blocks ||= []
    end

    # @return [Array<Proc>]
    def finish_blocks
      @finish_blocks ||= []
    end

    # @param rig [Class<Rig::Default>]
    # @param type [String, nil]
    # @param on_start [Proc, nil]
    # @param on_finish [Proc, nil]
    # @yieldparam [self]
    def initialize rig: Rig::Default, type: nil, on_start: nil, on_finish: nil
      @rig = rig
      @type = type
      start_blocks.push on_start if on_start
      finish_blocks.push on_finish if on_finish
      yield(self) if block_given?
    end

    def type
      @type ||= rig.to_s.split('::').last
    end

    # @yieldparam [Actor]
    # @yieldparam [SceneProps::Default]
    def on_start &block
      start_blocks.push block
    end

    # @yieldparam [Actor]
    # @yieldparam [SceneProps::Default]
    def on_finish &block
      finish_blocks.push block
    end

    def to_sym
      name
    end
  end
end
