# frozen_string_literal: true

module Gamefic
  class Scenebook
    # @return [Array<Proc>]
    attr_reader :ready_blocks

    # @return [Array<Proc>]
    attr_reader :player_ready_blocks

    # @return [Array<Proc>]
    attr_reader :update_blocks

    # @return [Array<Proc>]
    attr_reader :player_update_blocks

    # @return [Array<Proc>]
    attr_reader :player_conclude_blocks

    # @return [Array<Proc>]
    attr_reader :player_output_blocks

    def initialize
      @scene_map = {}
      @ready_blocks = []
      @player_ready_blocks = []
      @update_blocks = []
      @player_update_blocks = []
      @player_conclude_blocks = []
      @player_output_blocks = []

      add_default_blocks
    end

    # Block a scene in the scenebook.
    #
    # @raise [NameError] if a scene with the given name already exists
    #
    # @param name [Symbol]
    # @param rig [Class<Scene::Rig::Base>]
    # @param type [String, nil]
    # @param on_start [Proc, nil]
    # @param on_finish [Proc, nil]
    # @param block [Proc]
    # @return [Scene]
    def block name, rig: Scene::Rig::Base, type: nil, on_start: nil, on_finish: nil, &block
      add Scene.new(name, rig: rig, type: type, on_start: on_start, on_finish: on_finish, &block)
    end

    # Add a scene to the scenebook.
    #
    # @raise [NameError] if a scene with the given name already exists
    #
    # @param [Scene]
    # @return [Scene]
    def add scene
      raise NameError, "A scene named `#{name}` already exists" if scene_map.key?(scene.name)

      scene_map[scene.name] = scene
    end

    # @param name [Symbol]
    # @return [Scene]
    def [](name)
      scene_map[name]
    end

    # @param name [Symbol]
    def scene?(name)
      scene_map.key?(name)
    end

    # @return [Array<Symbol>]
    def names
      scene_map.names
    end

    # @return [Array<Scene>]
    def scenes
      scene_map.values
    end

    def freeze
      super
      instance_variables.each { |k| instance_variable_get(k).freeze }
    end

    # @return [Proc]
    def on_ready &block
      ready_blocks.push block
    end

    # @yieldparam [Actor]
    # @return [Proc]
    def on_player_ready &block
      player_ready_blocks.push block
    end

    def on_update &block
      update_blocks.push block
    end

    def on_player_update &block
      player_update_blocks.push block
    end

    # @yieldparam [Actor]
    # @return [Proc]
    def on_player_conclude &block
      player_conclude_blocks.push block
    end

    # @yieldparam [Actor]
    # @yieldparam [Hash]
    # @return [Proc]
    def on_player_output &block
      player_output_blocks.push block
    end

    def run_player_ready_blocks player
      player_ready_blocks.each { |blk| blk.call player }
    end

    def run_player_output_blocks player, output
      player_output_blocks.each { |blk| blk.call player, output }
      player.output.replace output
    end

    private

    attr_reader :scene_map

    def add_default_blocks
      on_player_output do |player, output|
        output[:messages] += player.messages
        output[:queue] = player.queue
        player.flush
      end
    end
  end
end
