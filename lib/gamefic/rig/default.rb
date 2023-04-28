# frozen_string_literal: true

module Gamefic
  module Rig
    # A Rig provides a framework for processing scenes, including handling
    # input and output. The Default does not provide any functionality on its
    # own, but can be subclassed or extended through callbacks.
    #
    class Default
      # A collection of data associated with the plot.
      #
      # @return [Props::Default]
      attr_reader :props

      attr_reader :context

      # @param scene [Scene, nil]
      # @param context [Hash]
      def initialize scene, **context
        @props = props_class.new(scene&.name, scene&.type, **context)
        @context = context
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
