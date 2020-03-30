module Gamefic
  # The simplest class that can compose an object for use in a plot.
  # Most game objects, especially tangible items in the game, should derive
  # from the Entity class. Elements, on the other hand, can be used for
  # abstractions and ideas that don't have a physical presence but still might
  # need to be referenced in a command.
  #
  class Element
    include Gamefic::Describable
    # include Gamefic::Index
    include Gamefic::Serialize

    # @todo It would be nice if this initialization wasn't necessary.
    def initialize(args = {})
    # super self.class.default_attributes.merge(args)
    self.class.default_attributes.merge(args).each_pair do |k, v|
      public_send "#{k}=", v
    end
    post_initialize
    yield self if block_given?
    end

    def post_initialize
      # raise NotImplementedError, "#{self.class} must implement post_initialize"
    end

    class << self
      # Set or update the default values for new instances.
      #
      # @param attrs [Hash] The attributes to be merged into the defaults.
      def set_default attrs = {}
        default_attributes.merge! attrs
      end

      # A hash of default values for attributes when creating an instance.
      #
      # @return [Hash]
      def default_attributes
        @default_attributes ||= {}
      end

      def inherited subclass
        subclass.set_default default_attributes
      end
    end
  end
end
