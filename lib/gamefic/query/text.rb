# frozen_string_literal: true

module Gamefic
  module Query
    # A special query that handles text instead of entities.
    #
    class Text < Base
      # @param argument [String, Regexp]
      # @param name [String, nil]
      def initialize argument = /.*/, name: self.class.name
        super(argument, name: name)
        validate_argument
      end

      def argument
        arguments.first
      end

      # @return [String, Regexp]
      def select(_subject)
        argument
      end

      def query _subject, token
        if match? token
          Result.new(token, '')
        else
          Result.new(nil, token)
        end
      end
      alias filter query

      def precision
        -10_000
      end

      def accept? _subject, token
        match?(token)
      end

      private

      def match? token
        return false unless token.is_a?(String) && !token.empty?

        case argument
        when Regexp
          token.match?(argument)
        else
          argument == token
        end
      end

      def validate_argument
        return if argument.is_a?(String) || argument.is_a?(Regexp)

        raise ArgumentError, 'Invalid text query argument'
      end
    end
  end
end
