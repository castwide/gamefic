# frozen_string_literal: true

module Gamefic
  module Rig
    # A Rig provides a framework for processing scenes, including handling
    # input and output.
    #
    # Gamefic provides a few different types of rigs to facilitate a variety
    # of scene types, such as Activity (text-based commands), MultipleChoice
    # (requiring the user to select from a list of options), and Pause. The
    # easiest way to author custom scenes is to block them using a predefined
    # rig and adding functionality through callbacks. Gamefic::World::Scenes
    # provides some helper methods for defining scenes from Plot scripts.
    #
    class Default
      # @param scene [Scene, nil]
      # @param context [Hash]
      def initialize scene, **context
        @scene = scene
        @context = context
      end

      # A collection of data associated with the plot.
      #
      # @return [Props::Default]
      def props
        @props ||= props_class.new(@scene, **@context)
      end

      def cancelled?
        !!@cancelled
      end

      # Cancel the rig's current scene. Cancelling will stop execution of any
      # remaining callbacks.
      #
      # @return [void]
      def cancel
        @cancelled = true
      end

      # The start of the scene. Subclasses can override this method
      # to provide special handling.
      #
      # @param actor [Gamefic::Active]
      # @return [void]
      def start actor; end

      # A method triggered after the scene has started and before the
      # user is prompted for input. Subclasses can override it if the props
      # need any additional processing before sending output to the user.
      #
      # @return [void]
      def ready; end

      # Process the end of the scene. The base method reads the next line of
      # input from the actor's queue. Subclasses that override it should call
      # `super` to ensure that the queue doesn't get out of sync.
      #
      # @param actor [Gamefic::Active]
      # @return [void]
      def finish actor
        props.input = actor.queue.shift&.strip
      end

      # @return [Class<Props::Default>]
      def props_class
        self.class.props_class
      end

      class << self
        # @return [Class<Props::Default>]
        def props_class
          @props_class ||= Props::Default
        end

        # @param klass [Class<Props::Default>]
        # @return [Class<Props::Default>]
        def use_props_class klass
          @props_class = klass
        end
      end
    end
  end
end
