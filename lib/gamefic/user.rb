module Gamefic
  class User
    # @param input [IO] The stream that receives input
    # @param output [IO] The stream that sends output
    def initialize input: STDIN, output: STDOUT
      @input = input
      @output = output
    end

    # Update the user with a hash of data representing the current game state.
    #
    # @param data [Hash]
    # @return [void]
    def update state
      @output.write state_to_text(state)
    end

    # Convert a hash of data (i.e., the current game state) into a string that
    # can be processed by the user agent. The base implementation converts the
    # data to JSON.
    #
    # @param state [Hash]
    # @return [String]
    def state_to_text state
      state.to_json
    end

    # Get input from the user.
    #
    # @return [String, nil]
    def query
      @input.gets
    end

    # @param filename [String]
    # @param snapshot [Hash]
    def save filename, snapshot
      STDERR.puts "The save feature is not implemented in #{self.class}."
    end

    # @param filename [String]
    def restore filename
      STDERR.puts "The restore feature is not implemented in #{self.class}."
    end
  end
end
