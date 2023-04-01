# frozen_string_literal: true

module Gamefic
  class Scene
    module Rig
      # A rig provides a framework for processing scenes and handling input.
      #
      class Base
        def initialize **context
          @context = context
        end

        def props
          @props ||= prop_class.new(**@context)
        end

        def cancelled?
          !!@cancelled
        end

        def cancel
          @cancelled = true
        end

        # @param actor [Gamefic::Active]
        # @return [void]
        def start actor
          props.output[:messages] += actor.messages
          # @todo Flush here?
        end

        # @param actor [Gamefic::Active]
        # @return [void]
        def finish actor
          props.input = actor.queue.shift
        end

        # @return [Class<Scene::Props::Base>]
        def prop_class
          self.class.prop_class
        end

        class << self
          # @return [Class<Scene::Props::Base>]
          def prop_class
            @prop_class ||= Scene::Props::Base
          end

          # @param klass [Class<Scene::Props::Base>]
          # @return [Class<Scene::Props::Base>]
          def use_prop_class klass
            @prop_class = klass
          end
        end
      end
    end
  end
end
