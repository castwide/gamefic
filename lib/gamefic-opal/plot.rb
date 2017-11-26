module Gamefic
  module Opal
    class Plot < Gamefic::Plot
      def script path
      end
      def method_missing symbol, *args, &block
        raise NameError.new("undefined local or variable method #{symbol}")
      end
    end
  end
end
