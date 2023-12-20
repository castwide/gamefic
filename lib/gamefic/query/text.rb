# frozen_string_literal: true

module Gamefic
  module Query
    class Text
      # A special query that handles text instead of entities.
      #
      # @param argument [String, Regexp, nil]
      def initialize argument = nil
        @argument = argument
        validate
      end

      def query _subject, token
        if match? token
          Result.new(token, '')
        else
          Result.new(nil, token)
        end
      end

      def precision
        0
      end

      private

      def match? token
        return true if @argument.nil?

        case @argument
        when Regexp
          token =~ @argument
        else
          token == @argument
        end
      end

      def validate
        return if @argument.nil? || @argument.is_a?(String) || @argument.is_a?(Regexp)

        raise ArgumentError, 'Invalid text query argument'
      end
    end
  end
end
