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

      def prompt
        @prompt ||= '>'
      end

      def output
        @output ||= Props::Output.new
      end

      # @param text [String]
      def enter(text)
        @input = text
      end
    end
  end
end
