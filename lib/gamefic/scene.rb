# frozen_string_literal: true

require 'gamefic/scene/props'
require 'gamefic/scene/type'

module Gamefic
  # A Scene provides blocks to be executed at the start and finish of a turn.
  # Plots execute Scenes by creating Takes.
  #
  class Scene
    # @return [Symbol]
    attr_reader :name

    # @return [Class<SceneType::Base>]
    attr_reader :type

    # @return [Proc]
    attr_reader :start_block

    # @return [Proc]
    attr_reader :finish_block

    # @param name [Symbol]
    # @param type [Class<SceneType::Base>]
    # @param on_start [Proc, nil]
    # @param on_finish [Proc, nil]
    # @param block [Proc]
    def initialize name, type: Scene::Type::Base, on_start: nil, on_finish: nil, &block
      @name = name
      @type = type
      @start_block = on_start
      @finish_block = on_finish
      # @todo Is yield or yield_self valid here?
      block&.call(self)
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
