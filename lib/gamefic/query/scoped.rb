module Gamefic
  module Query
    class Scoped < Base
      # @param scope [Class<Gamefic::Scope::Base>]
      # @param args [Array<Object>]
      # @param ambiguous [Boolean]
      def initialize scope, *args, ambiguous: false, eid: nil
        super(*args)
        @scope = scope
        @ambiguous = ambiguous
        @eid = eid
      end

      # @return [Result]
      def query(subject, token)
        available = @scope.matches(subject)
                         .that_are(*@args)
        available.select! { |e| e.id == @eid } if @eid

        scan = Scanner.scan(available, token)

        return ambiguous_result(scan) if ambiguous?

        unambiguous_result(scan)
      end

      def precision
        @precision ||= @scope.precision + calculate_precision
      end

      def ambiguous?
        @ambiguous
      end
    end
  end
end
