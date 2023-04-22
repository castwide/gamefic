# frozen_string_literal: true

module Gamefic
  class Scenebook
    attr_reader :player_ready_blocks

    attr_reader :player_update_blocks

    attr_reader :player_output_blocks

    attr_reader :player_conclude_blocks

    attr_reader :ready_blocks

    def initialize
      @scene_map = {}
      @ready_blocks = []
      @player_ready_blocks = []
      @update_blocks = []
      @player_update_blocks = []
      @player_conclude_blocks = []
      @player_output_blocks = []
    end

    # Add a scene to the scenebook.
    #
    # @param [Scene]
    def add scene
      raise ArgumentError, "A scene named `#{scene.name} already exists" if @scene_map.key?(scene.name)

      @scene_map[scene.name] = scene
    end

    def scene? name
      @scene_map.key? name
    end

    # @return [Scene, nil]
    def [](name)
      @scene_map[name]
    end

    # @return [Array<Symbol>]
    def names
      @scene_map.keys
    end

    # @return [Array<Scene>]
    def scenes
      @scene_map.values
    end

    def freeze
      super
      instance_variables.each { |k| instance_variable_get(k).freeze }
      self
    end

    # @return [Proc]
    def on_ready &block
      @ready_blocks.push block
    end

    # @yieldparam [Actor]
    # @return [Proc]
    def on_player_ready &block
      @player_ready_blocks.push block
    end

    def on_update &block
      @update_blocks.push block
    end

    def on_player_update &block
      @player_update_blocks.push block
    end

    # @yieldparam [Actor]
    # @return [Proc]
    def on_player_conclude &block
      @player_conclude_blocks.push block
    end

    # @yieldparam [Actor]
    # @yieldparam [Hash]
    # @return [Proc]
    def on_player_output &block
      @player_output_blocks.push block
    end

    def run_update_blocks
      @update_blocks.each(&:call)
    end
  end
end
