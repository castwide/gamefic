module Gamefic
  module Library
    class Base
      @@subclasses = []

      def name
        @name ||= self.class.to_s.split('::').last.downcase
      end

      def path
        nil
      end

      def self.inherited(subclass)
        @@subclasses.push subclass
      end

      def self.subclasses
        @@subclasses.clone
      end

      def self.name
        self.new.name
      end

      def self.path
        self.new.path
      end
    end
  end
end
