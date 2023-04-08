# frozen_string_literal: true

module Gamefic
  # An object that acts as a delegate between entity instances in a plot and
  # entity references in the plot's theater.
  #
  # Proxies allow scripts to retain static references to entities across plot
  # restorations. When a plot gets restored from a snapshot, the variables in
  # the script that reference entities should point correctly to the restored
  # entities.
  #
  # Proxies and entities are designed to be interchangeable. Authors should
  # not need to care whether a variable points to a proxy or an entity.
  #
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

    if RUBY_ENGINE == 'opal' || RUBY_VERSION =~ /^2\.[456]\./
      def method_missing symbol, *args, &block
        host.entities[index].public_send symbol, *args, &block
      end
    else
      def method_missing symbol, *args, **splat, &block
        host.entities[index].public_send symbol, *args, **splat, &block
      end
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
