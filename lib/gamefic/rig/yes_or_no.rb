# frozen_string_literal: true

module Gamefic
  module Rig
    # A specialized MultipleChoice rig that only accepts Yes or No.
    #
    class YesOrNo < MultipleChoice
      use_props_class Props::YesOrNo

      private

      def index_by_text
        return nil if props.input.empty?

        props.options.find_index { |text| text.downcase.start_with?(props.input.downcase) }
      end
    end
  end
end
