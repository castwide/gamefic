module Gamefic

  # The base user provides methods for handling messages received from plots.
  #
  class User::Base
    def send message
      buffer.send message
    end

    def flush
      buffer.flush
    end

    private

    def buffer
      @buffer ||= User::Buffer.new
    end
  end

end
