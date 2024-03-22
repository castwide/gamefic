# frozen_string_literal: true

module Gamefic
  module Query
    # A special query that handles text instead of entities.
    #
    class Text
      # @param argument [String, Regexp, nil]
      def initialize argument = nil
        @argument = argument
        validate
      end

      def select(_subject)
        [@argument]
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

      def accept? _subject, argument
        match? argument
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
