module Gamefic

  # A simple buffer class for collecting and returning data received from
  # plots.
  class User::Buffer
    def initialize
      @data = ''
    end

    # Append a message to the buffer.
    def send message
      @data += message
    end

    # Read the current buffer without clearing it.
    #
    # @return [String]
    def peek
      @data
    end

    # Get the current data and clear the buffer.
    #
    # @return [String]
    def flush
      tmp = @data
      @data = ''
      tmp
    end
  end

end
