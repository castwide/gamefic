module Gamefic

  class User::Buffer
    def initialize
      @data = ''
    end

    def send message
      @data += message
    end

    def flush
      tmp = @data
      @data = ''
      tmp
    end
  end

end
