module Gamefic
  module Serialized
    def serialized_attributes
      self.class.serializer.keys
    end
    module ClassMethods
      def serialize *args
        args.each { |a|
          serializer[a] = nil
        }
      end
      def serializer
        @@serialized_attributes ||= from_superclass(:serializer, {}).dup
      end
      private
      def from_superclass(m, default = nil)
        superclass.respond_to?(m) ? superclass.send(m) : default
      end
    end
    def self.included(base)
      base.extend(Gamefic::Serialized::ClassMethods)
    end
  end
end
