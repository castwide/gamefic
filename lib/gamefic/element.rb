module Gamefic
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
