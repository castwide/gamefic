module Gamefic
  module World
    module Theater
      # Execute a block of code in a subset of the object's scope. An object's
      # stage is an isolated namespace that has its own instance variables and
      # access to its owner's public methods.
      #
      # There are two ways to execute code on the stage. It will accept either a
      # string of code with an optional file name and line number, or a proc
      # with optional arguments. See module_eval and module_exec for more
      # information.
      #
      # @example Evaluate a string of code
      #   stage "puts 'Hello'"
      #
      # @example Evaluate a string of code with a file name and line number
      #   stage "puts 'Hello'", "file.rb", 1
      #
      # @example Execute a block of code
      #   stage {
      #     puts 'Hello'
      #   }
      #
      # @example Execute a block of code with arguments
      #   stage 'hello' { |message|
      #     puts message # <- prints 'hello'
      #   }
      #
      # @example Use an instance variable
      #   stage "@message = 'hello'"
      #   stage "puts @message" # <- prints 'hello'
      #
      # @return [Object] The value returned by the executed code
      def stage *args, &block
        if block.nil?
          theater.module_eval *args
        else
          theater.module_exec *args, &block
        end
      end

      # The module that acts as an isolated namespace for staged code.
      #
      # @return [Module]
      def theater
        return @theater unless @theater.nil?
        instance = self

        # @type [Module]
        @theater = Module.new do
          define_singleton_method :method_missing do |symbol, *args, &block|
            instance.public_send :public_send, symbol, *args, &block
          end

          define_singleton_method :stage do |*args|
            raise NoMethodError.new("The stage method is not available from inside staged scripts")
          end

          define_singleton_method :to_s do
            "[Theater]"
          end
        end

        # HACK: Include the theater module in Object so that classes and modules
        # defined in scripts are accessible from procs passed to the stage.
        Object.class_exec(@theater) do |t|
          include t
        end

        @theater
      end
    end
  end
end
