module Gamefic

  class User::Base
    def initialize
      @buffer = ''
    end
    def send message
      @buffer += message
    end
    def recv prompt = '>'
      print "#{prompt} "
      STDOUT.flush
      STDIN.gets
    end
    def flush
      tmp = @buffer
      @buffer = ''
      tmp
    end
  end

end
