# frozen_string_literal: true

module Gamefic
  # A cleanroom container for running plot scripts and maintaining related
  # objects. Theaters give authors a place where they can maintain their own
  # variables and other resources without polluting the plot's namespace.
  #
  class Theater
    # @param director [Object]
    # @param delegators [Array<Module>]
    def initialize director, delegators
      # define_method_missing director, delegators
    end

    def evaluate director, *args, block
      return unless block

      directors.push director
      result = instance_exec *args, &block
      directors.pop
      result
    end

    def inspect
      "#<#{self.class}>"
    end

    if RUBY_ENGINE == 'opal' || RUBY_VERSION =~ /^2\.[456]\./
      instance_eval do
        define_method :method_missing do |symbol, *args, &block|
          # raise NoMethodError, "#{self} cannot delegate method `#{symbol}` to #{director}" unless delegated.include?(symbol)

          directors.last.public_send symbol, *args, &block
        end
      end
    else
      instance_eval do
        define_method :method_missing do |symbol, *args, **splat, &block|
          # raise NoMethodError, "#{self} cannot delegate method `#{symbol}` to #{director}" unless delegated.include?(symbol)

          directors.last.public_send symbol, *args, **splat, &block
        end
      end
    end

    instance_eval do
      define_method :respond_to_missing? do |symbol, private|
        return false if private

        # delegated.include?(symbol)
        directors.last.methods.include?(symbol)
      end

      director_array = []
      define_method(:directors) { director_array }
    end
  end
end
