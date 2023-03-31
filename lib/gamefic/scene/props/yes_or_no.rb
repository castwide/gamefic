# frozen_string_literal: true

module Gamefic
  class Scene
    module Props
      class YesOrNo < MultipleChoice
        def yes?
          selection == 'Yes'
        end

        def no?
          selection == 'No'
        end

        def options
          @options ||= ['Yes', 'No'].freeze
        end
      end
    end
  end
end
