# frozen_string_literal: true

module Gamefic
  class Rulebook
    class Scenes
      attr_reader :introductions

      def initialize
        @scene_map = {}
        @introductions = []
      end

      def freeze
        super
        @scene_map.freeze
        @introductions.freeze
        self
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
      def all
        @scene_map.values
      end

      def introduction scene
        introductions.push scene
      end

      def empty?
        @scene_map.empty? && introductions.empty?
      end
    end
  end
end
