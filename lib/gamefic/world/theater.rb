# @note Theater is implemented this way so the clean room object defines its
#   classes and modules in the root namespace.
Gamefic::World::Theater = Module.new do
  define_method :stage do |*args, &block|
    if block.nil?
      theater.instance_exec do
        eval *([args[0], theater.send(:binding)] + args[1..-1])
      end
    else
      theater.instance_exec *args, &block
    end
  end

  define_method :theater do
    @theater ||= begin
      instance = self
      theater ||= Object.new
      theater.instance_exec do
        define_singleton_method :method_missing do |symbol, *args, &block|
          instance.public_send :public_send, symbol, *args, &block
        end
      end
      theater
    end
  end
  alias cleanroom theater
end

# The Theater provides a clean room for executing plot scripts.
#
module Gamefic::World::Theater
  # @!method stage(*args, &block)
  #   Execute a block of code in a subset of the object's scope. An object's
  #   stage is an isolated namespace that has its own instance variables and
  #   access to its owner's public methods.
  #
  #   There are two ways to execute code on the stage. It will accept either a
  #   string of code with an optional file name and line number, or a proc
  #   with optional arguments. See module_eval and module_exec for more
  #   information.
  #
  #   @example Evaluate a string of code
  #     stage "puts 'Hello'"
  #
  #   @example Evaluate a string of code with a file name and line number
  #     stage "puts 'Hello'", "file.rb", 1
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
  #     stage "@message = 'hello'"
  #     stage "puts @message" # <- prints 'hello'
  #
  #   @yieldself [self]
  #   @return [Object] The value returned by the executed code

  # @!method theater
  #   The module that acts as an isolated namespace for staged code.
  #
  #   @return [Object]
end
