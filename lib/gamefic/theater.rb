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
      define_method_missing director, delegators
    end

    def evaluate *args, block
      return unless block

      instance_exec *args, &block
    end

    def inspect
      "#<#{self.class}>"
    end

    protected

    # @param director [Object]
    # @param delegators [Array<Module>]
    # @return [void]
    def define_method_missing director, delegators
      delegated = delegators.compact.flat_map(&:public_instance_methods)

      if RUBY_ENGINE == 'opal' || RUBY_VERSION =~ /^2\.[456]\./
        self.class.instance_eval do
          define_method :method_missing do |symbol, *args, &block|
            raise NoMethodError, "#{self} cannot delegate method `#{symbol}` to #{director}" unless delegated.include?(symbol)

            director.public_send symbol, *args, &block
          end
        end
      else
        self.class.instance_eval do
          define_method :method_missing do |symbol, *args, **splat, &block|
            raise NoMethodError, "#{self} cannot delegate method `#{symbol}` to #{director}" unless delegated.include?(symbol)

            director.public_send symbol, *args, **splat, &block
          end
        end
      end

      self.class.instance_eval do
        define_method :respond_to_missing? do |symbol, private|
          return false if private
    
          delegated.include?(symbol)
        end    
      end
    end
  end
end
