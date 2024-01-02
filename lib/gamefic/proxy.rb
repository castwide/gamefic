module Gamefic
  class Proxy
    attr_reader :symbol

    attr_reader :string

    def initialize symbol
      @symbol = symbol.to_sym
      @string = symbol.to_s
    end

    def fetch narrative
      if string.start_with?('@')
        narrative.instance_variable_get(symbol)
      else
        narrative.send(symbol)
      end
    end
  end
end
