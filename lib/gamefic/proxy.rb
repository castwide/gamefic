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
      freeze
    end

    # @return [Gamefic::Entity]
    def entity
      host.entities[index]
    end

    def ==(other)
      case other
      when Gamefic::Entity, Gamefic::Proxy
        other.entity == entity
      else
        false
      end
    end

    def method_missing symbol, *args, **splat, &block
      host.entities[index].public_send symbol, *args, **splat, &block
    end

    def respond_to_missing? symbol, private
      return false if private
      host.entities[index].public_methods.include? symbol
    end

    def is_a?(klass)
      entity.is_a?(klass)
    end
  end
end
