# frozen_string_literal: true

module Gamefic
  module Scene
    module Type
      class Base
        PROPS = SceneProps::Base

        def props
          @props ||= PROPS.new
        end

        def cancelled?
          !!@cancelled
        end

        def cancel
          @cancelled = true
        end

        def start actor; end

        def finish actor
          props.update input: actor.queue.shift
        end
      end
    end
  end
end
