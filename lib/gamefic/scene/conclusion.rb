# frozen_string_literal: true

module Gamefic
  module Scene
    # A scene that ends an actor's participation in a narrative.
    #
    class Conclusion < Default
      def self.conclusion?
        true
      end

      def self.type
        'Conclusion'
      end
    end
  end
end
