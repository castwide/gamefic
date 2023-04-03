module Gamefic
  class Theater
    def initialize plot
      if RUBY_ENGINE == 'opal' || RUBY_VERSION =~ /^2\.[456]\./
        define_singleton_method :method_missing do |symbol, *args, &block|
          if Scripting.public_instance_methods.include?(symbol)
            plot.public_send symbol, *args, &block
          else
            super symbol, *args, &block
          end
        end
      else
        define_singleton_method :method_missing do |symbol, *args, **splat, &block|
          if Scripting.public_instance_methods.include?(symbol)
            plot.public_send symbol, *args, **splat, &block
          else
            super symbol, *args, **splat, &block
          end
        end
      end
    end
  end
end
