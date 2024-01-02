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
        Stage.run(narrative, symbol) { |sym| instance_variable_get(sym) }
      else
        Stage.run(narrative, symbol) { |sym| send(sym) }
      end
    end
  end
end
