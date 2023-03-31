# frozen_string_literal: true

require 'gamefic/scene/props'
require 'gamefic/scene/rig'

module Gamefic
  # A Scene provides blocks to be executed at the start and finish of a turn.
  # Plots execute Scenes by creating Takes.
  #
  class Scene
    # @return [Symbol]
    attr_reader :name

    # @return [Class<Scene::Rig::Base>]
    attr_reader :rig

    # @return [Proc]
    attr_reader :start_block

    # @return [Proc]
    attr_reader :finish_block

    # @param name [Symbol]
    # @param rig [Class<Scene::Rig::Base>]
    # @param type [String, nil]
    # @param on_start [Proc, nil]
    # @param on_finish [Proc, nil]
    # @yieldparam [self]
    def initialize name, rig: Scene::Rig::Base, type: nil, on_start: nil, on_finish: nil
      @name = name
      @rig = rig
      @type = type
      @start_block = on_start
      @finish_block = on_finish
      yield(self) if block_given?
    end

    def type
      @type ||= rig.to_s.split('::').last
    end

    # @yieldparam [Actor]
    # @yieldparam [SceneProps::Base]
    def on_start &block
      @start_block = block
    end

    # @yieldparam [Actor]
    # @yieldparam [SceneProps::Base]
    def on_finish &block
      @finish_block = block
    end
  end
end
