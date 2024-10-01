# frozen_string_literal: true

module Gamefic
  module Scanner
    # A base class for scanners that match tokens to entities.
    #
    class Base
      # @return [Array<Entity>]
      attr_reader :selection

      # @return [String]
      attr_reader :token

      # @param selection [Array<Entity>]
      # @param token [String]
      def initialize selection, token
        @selection = selection
        @token = token
      end

      # @return [Result]
      def scan
        unmatched_result
      end

      # @param selection [Array<Entity>]
      # @param token [String]
      # @return [Result]
      def self.scan selection, token
        new(selection, token).scan
      end

      private

      def unmatched_result
        Result.unmatched(selection, token, self.class)
      end
    end
  end
end
