module Gamefic
  # The simplest class that can compose an object for use in a plot.
  # Most game objects, especially tangible items in the game, should derive
  # from the Entity class. Elements, on the other hand, can be used for
  # abstractions and ideas that don't have a physical presence but still might
  # need to be referenced in a command.
  #
  class Element
    include Gamefic::Describable

    def initialize(args = {})
      self.class.default_attributes.merge(args).each { |key, value|
        send "#{key}=", value
      }
      post_initialize
      yield self if block_given?
    end

    def post_initialize
      # raise NotImplementedError, "#{self.class} must implement post_initialize"
    end

    class << self
      def set_default attrs = {}
        default_attributes.merge! attrs
      end

      def default_attributes
        @default_attributes ||= {}
      end

      def inherited subclass
        subclass.set_default default_attributes
      end
    end
  end
end
