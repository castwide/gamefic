module Gamefic
  module Query
    class Relative < Abstract
      # @param context [Gamefic::Entity]
      # @param scope [Class<Scope::Base>]
      # @param args [Array<Filter>]
      # @param eid [Symbol, nil]
      def initialize context, scope, *args, eid: nil
        @context = context
        @scope = scope
        @args = args
        @eid = eid
      end

      def matches
        filtered = @scope.matches(@context)
                         .that_are(*@args)
        return filtered if @eid.nil?

        filtered.select { |e| e.id == @eid }
        # @todo Handle the text now
      end
    end
  end
end
