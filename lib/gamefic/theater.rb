# frozen_string_literal: true

module Gamefic
  # A cleanroom container for running plot scripts and maintaining related
  # objects. Theaters give authors a place where they can maintain their own
  # variables and other resources without polluting the plot's namespace.
  #
  class Theater
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

    instance_eval do
      if RUBY_ENGINE == 'opal' || RUBY_VERSION =~ /^2\.[456]\./
        define_method :method_missing do |symbol, *args, &block|
          raise NoMethodError, "#{director} cannot delegate method #{symbol}" unless director.delegator.public_instance_methods.include?(symbol)

          director.public_send symbol, *args, &block
        end
      else
        define_method :method_missing do |symbol, *args, **splat, &block|
          raise NoMethodError, "#{director} cannot delegate method #{symbol}" unless director.delegator.public_instance_methods.include?(symbol)

          director.public_send symbol, *args, **splat, &block
        end
      end

      define_method :respond_to_missing? do |symbol, include_all|
        director.respond_to?(symbol, include_all)
      end

      director_array = []
      define_method(:directors) { director_array }
      define_method(:director) { director_array.last }
    end
  end
end
