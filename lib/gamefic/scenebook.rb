# frozen_string_literal: true

module Gamefic
  class Scenebook
    include Logging

    attr_reader :player_output_blocks

    attr_reader :player_conclude_blocks

    attr_reader :ready_blocks

    attr_reader :conclude_blocks

    attr_reader :introductions

    def initialize stage
      @stage = stage
      @scene_map = {}
      @ready_blocks = []
      @update_blocks = []
      @conclude_blocks = []
      @player_conclude_blocks = []
      @player_output_blocks = []
      @introductions = []
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

    def introduction scene = nil
      introductions.push scene
    end

    # @return [Proc]
    def on_ready &block
      @ready_blocks.push(proc do
        @stage.call &block
      end)
    end

    # @yieldparam [Actor]
    # @return [Proc]
    def on_player_ready &block
      @ready_blocks.push(proc do
        @stage.call { players }.each { |plyr| @stage.call plyr, &block }
      end)
    end

    def on_update &block
      @update_blocks.push(proc do
        @stage.call &block
      end)
    end

    def on_player_update &block
      @update_blocks.push(proc do
        @stage.call { players }.each { |plyr| @stage.call plyr, &block }
      end)
    end

    # @return [Proc]
    def on_conclude &block
      @conclude_blocks.push block
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

    def run_ready_blocks
      @ready_blocks.each(&:call)
    end

    def run_update_blocks
      @update_blocks.each(&:call)
    end

    def run_player_output_blocks player, output
      @player_output_blocks.each { |blk| @stage.call player, output, &blk }
    end

    def run_conclude_blocks
      @conclude_blocks.each { |blk| @stage.call &blk }
    end

    def run_player_conclude_blocks player
      @player_conclude_blocks.each { |blk| @stage.call player, &blk }
    end
  end
end
