# frozen_string_literal: true

module Gamefic
  module Scanner
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
        Result.unmatched(selection, token)
      end
    end
  end
end
