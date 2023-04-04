module Gamefic
  module Query
    class Text < Base
      include Abstract

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

      private

      def match? token
        case @arg
        when String
          token == @arg
        when Regexp
          token =~ @arg
        else
          true
        end
      end
    end
  end
end
