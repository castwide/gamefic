module Gamefic
  module Query
    class Text
      # A special query that handles text instead of entities.
      #
      # @param argument [String, Regexp, nil]
      def initialize argument = nil
        @argument = argument
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
        when String
          token == @argument
        when Regexp
          token =~ @argument
        else
          raise ArgumentError, 'Invalid text query argument'
        end
      end
    end
  end
end
