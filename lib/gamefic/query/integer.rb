# frozen_string_literal: true

module Gamefic
  module Query
    # A special query that handles integers instead of entities.
    #
    class Integer < Base
      # @param name [String, nil]
      def initialize(name: self.class.name)
        super(name: name)
      end

      def filter(_subject, token)
        return Result.new(token, '') if token.is_a?(::Integer)

        words = token.keywords
        number = words.shift
        return Result.new(nil, token) unless number =~ /\d+/

        Result.new(number.to_i, words.join(' '))
      end

      def precision
        -10_000
      end

      def accept?(_subject, token)
        token.is_a?(::Integer)
      end
    end
  end
end
