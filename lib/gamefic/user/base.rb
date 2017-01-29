module Gamefic

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
