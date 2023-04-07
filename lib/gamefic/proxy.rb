module Gamefic
  class Proxy
    # @return [Plot, Subplot]
    attr_reader :host

    # @return [Integer]
    attr_reader :index

    # @param host [Plot, Subplot]
    # @param index [Integer]
    def initialize host, index
      @host = host
      @index = index
    end

    # @return [Gamefic::Entity]
    def entity
      host.entities[index]
    end

    def method_missing symbol, *args, **splat, &block
      host.entities[index].send symbol, *args, **splat, &block
    end
  end
end
