# frozen_string_literal: true

module Gamefic
  class Scene
    module Type
      class Base
        def props
          @props ||= prop_class.new
        end

        def cancelled?
          !!@cancelled
        end

        def cancel
          @cancelled = true
        end

        # @param actor [Gamefic::Active]
        # @return [void]
        def start actor; end

        # @param actor [Gamefic::Active]
        # @return [void]
        def finish actor
          props.update input: actor.queue.shift
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
