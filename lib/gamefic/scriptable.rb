module Gamefic
  # The Scriptable module provides a clean room (aka "theater") for scripts.
  #
  # @!method stage(*args, &block)
  #   Execute a block of code in a subset of the owner's scope.
  #
  #   The provided code is evaluated inside a clean room object that has its
  #   own instance variables and access to the owner's public methods. The proc
  #   can accept the method call's arguments.
  #
  #   @example Execute a block of code
  #     stage {
  #       puts 'Hello'
  #     }
  #
  #   @example Execute a block of code with arguments
  #     stage 'hello' { |message|
  #       puts message # <- prints 'hello'
  #     }
  #
  #   @example Use an instance variable
  #     stage { @message = 'hello'" }
  #     stage { puts @message } # <- prints 'hello'
  #
  #   @yieldpublic [Gamefic::Plot]
  #   @return [Object] The value returned by the executed code
  #
  # @!method theater
  #   The object that acts as an isolated namespace for staged code.
  #   @return [Object]
  #
  # @!parse alias cleanroom theater
  module Scriptable
    module ClassMethods
      # An array of blocks that were added by the `script` class method.
      #
      # @return [Array<Proc>]
      def blocks
        @blocks ||= []
      end

      # Add a block to be executed by the instance's `stage` method.
      #
      # Note that `script` does not execute the block instantly, but stores
      # it in the `blocks` array to be executed later.
      #
      # @yieldpublic [Gamefic::Plot]
      def script &block
        blocks.push block
      end
    end

    def self.included klass
      klass.extend ClassMethods
    end

    private

    # Execute all the scripts that were added by the `script` class method.
    #
    def run_scripts
      self.class.blocks.each { |blk| stage &blk }
    end
  end
end

# @note #stage and #theater are implemented this way so the clean room object
#   defines its classes and modules in the root namespace.
Gamefic::Scriptable.module_exec do
  define_method :stage do |*args, &block|
    theater.instance_exec *args, &block
  end

  define_method :theater do
    @theater ||= begin
      instance = self
      theater ||= Object.new
      theater.instance_exec do
        if RUBY_ENGINE == 'opal' || RUBY_VERSION =~ /^2\.[456]\./
          define_singleton_method :method_missing do |symbol, *args, &block|
            instance.public_send :public_send, symbol, *args, &block
          end
        else
          define_singleton_method :method_missing do |symbol, *args, **splat, &block|
            instance.public_send :public_send, symbol, *args, **splat, &block
          end
        end
      end
      theater.extend Gamefic::Serialize
      theater
    end
  end
  alias cleanroom theater
end
