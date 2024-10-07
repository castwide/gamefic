# frozen_string_literal: true

module Gamefic
  module Active
    # The combination of an actor and a scene to be performed in a plot turn.
    #
    class Take
      # @return [Active]
      attr_reader :actor

      # @return [Active::Cue]
      attr_reader :cue

      # @return [Scene::Default]
      attr_reader :scene

      # @param actor [Active]
      # @param cue [Active::Cue]
      # @param props [Props::Default, nil]
      def initialize actor, cue, props = nil
        @actor = actor
        @cue = cue
        @scene = actor.epic.select_scene(cue.scene).new(nil)
        @props = props
      end

      # @return [Props::Default]
      def props
        @props ||= @scene.new_props(**cue.context)
      end

      # @return [Props::Default]
      def start
        scene.run_start_blocks actor, props
        scene.start actor, props
        # @todo See if this can be handled better
        actor.epic.rulebooks.each { |rlbk| rlbk.run_player_output_blocks actor, props.output }
        props.output.merge!({
                              messages: actor.messages,
                              queue: actor.queue
                            })
        props
      end

      # @return [void]
      def finish
        actor.flush
        scene.finish(actor, props)
        scene.run_finish_blocks actor, props
      end

      class << self
        # @param actor [Active]
        # @param cue [Active::Cue]
        # @return [Props::Default]
        def start actor, cue
          Take.new(actor, cue).start
        end

        # @param actor [Active]
        # @param cue [Active::Cue]
        # @return [void]
        def finish actor, cue, props
          Take.new(actor, cue, props).finish
        end
      end
    end
  end
end
