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

    if RUBY_ENGINE == 'opal' || RUBY_VERSION =~ /^2\.[456]\./
      instance_eval do
        define_method :method_missing do |symbol, *args, &block|
          raise NoMethodError, "#{self} cannot delegate method `#{symbol}` to #{directors.last}" unless directors.last.respond_to?(symbol, false)

          directors.last.public_send symbol, *args, &block
        end
      end
    else
      instance_eval do
        define_method :method_missing do |symbol, *args, **splat, &block|
          raise NoMethodError, "#{self} cannot delegate method `#{symbol}` to #{directors.last}" unless directors.last.respond_to?(symbol, false)

          directors.last.public_send symbol, *args, **splat, &block
        end
      end
    end

    instance_eval do
      define_method :respond_to_missing? do |symbol, include_all|
        directors.last.respond_to?(symbol, include_all)
      end

      director_array = []
      define_method(:directors) { director_array }
    end
  end
end
