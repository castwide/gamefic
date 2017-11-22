module Gamefic
  module Library
    class Base
      attr_reader :path

      @@subclasses = []

      def initialize
        post_initialize
      end

      def post_initialize
      end

      def name
        @name ||= self.class.to_s.split('::').last.downcase
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

      protected

      attr_writer :name
      attr_writer :path
    end
  end
end
