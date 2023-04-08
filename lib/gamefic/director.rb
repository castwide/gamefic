# frozen_string_literal: true

module Gamefic
  # A delegator for passing method calls from scripts to plots.
  #
  class Director
    # @param host [Object] The plot or subplot that will receive the calls
    # @param delegated [Array<Symbol>] The delegated methods
    def initialize host, delegated
      @host = host
      @delegated = delegated
      define_method_missing
      freeze
    end

    def respond_to_missing? symbol, private
      return false if private

      @delegated.include?(symbol)
    end

    private

    def define_method_missing
      if RUBY_ENGINE == 'opal' || RUBY_VERSION =~ /^2\.[456]\./
        define_singleton_method :method_missing do |symbol, *args, &block|
          raise NoMethodError, "#{self} cannot delegate method `#{symbol}` to #{@host}" unless @delegated.include?(symbol)

          @host.public_send symbol, *args, &block
        end
      else
        define_singleton_method :method_missing do |symbol, *args, **splat, &block|
          raise NoMethodError, "#{self} cannot delegate method `#{symbol}` to #{@host}" unless @delegated.include?(symbol)

          @host.public_send symbol, *args, **splat, &block
        end
      end
    end
  end
end
