module Gamefic
  module Opal
    class Plot < Gamefic::Plot
      def script path
        @executed ||= []
        return if @executed.include?(path)
        @executed.push path
        stage &@prepared_scripts[path]
      end

      def prepare_script path, &block
        @prepared_scripts ||= {}
        @prepared_scripts[path] = block
      end

      def method_missing symbol, *args, &block
        raise NameError.new("Plot received undefined method #{symbol}")
      end
    end
  end
end
