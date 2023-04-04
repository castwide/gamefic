module Gamefic
  module Query
    class Text
      def initialize arg = nil
        @arg = arg
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
        return true if @arg.nil?

        case @arg
        when String
          token == @arg
        when Regexp
          token =~ @arg
        else
          raise ArgumentError, 'Invalid text query argument'
        end
      end
    end
  end
end
