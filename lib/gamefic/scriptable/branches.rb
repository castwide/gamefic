# frozen_string_literal: true

module Gamefic
  module Scriptable
    module Branches
      # Start a new subplot based on the provided class.
      #
      # @param subplot_class [Class<Gamefic::Subplot>] The Subplot class
      # @param introduce [Gamefic::Actor, Array<Gamefic::Actor>, nil] Players to introduce
      # @param config [Hash] Subplot configuration
      # @return [Gamefic::Subplot]
      def branch subplot_class = Gamefic::Subplot, introduce: nil, **config
        subplot = subplot_class.new(self, introduce: introduce, **config)
        subplots.push subplot
        subplot
      end
    end
  end
end
