# frozen_string_literal: true

module Gamefic
  module Props
    # A collection of data related to a scene. Scenes define which Props class
    # they use. Props can be accessed in a scene's on_start and on_finish
    # callbacks.
    #
    # Props::Default includes the most common attributes that a scene requires.
    # Scenes are able but not required to subclass it. Some scenes, like
    # MultipleChoice, use specialized Props subclasses, but in many cases,
    # Props::Default is sufficient.
    #
    class Default
      # @return [String]
      attr_writer :prompt

      # @return [String]
      attr_accessor :input

      # A freeform dictionary of objects related to the scene. Plots can pass
      # opts to be included in the context when they cue scenes.
      #
      # @return [Hash]
      attr_reader :context
      alias data context

      # @param scene [Scene, nil]
      # @param context [Hash]
      def initialize name, type, **context
        @scene_name = name
        @scene_type = type
        @context = context
      end

      def prompt
        @prompt ||= '>'
      end
    end
  end
end
