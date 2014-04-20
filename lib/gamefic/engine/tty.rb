require 'gamefic/engine'
require 'thread'

module Gamefic

  module Tty
    class Engine < Gamefic::Engine
      def post_initialize
        @user = Tty::User.new @plot
      end
    end
    class User < Gamefic::User
      def post_initialize
        @stream = Tty::UserStream.new
        @state = UserState.new self
      end
    end
    class UserStream < Gamefic::UserStream
      def initialize
        super
      end
      def send(data)
        print "#{terminalize data}\n\n"
      end
      def select(prompt)
        print "#{terminalize prompt}"
        line = STDIN.gets
        puts "\n"
        @queue.push line.strip
      end
      def terminalize string, max_length = 80
        if max_length == nil
          return string
        end
        output = ''
        lines = string.split("\n")
        lines.each { |line|
          if line.size > max_length
            while (line.size > max_length)
              offset = line.rindex(/[\s\-]/, max_length)
              if (offset == 0 or offset == nil)
                output = output + line.strip + "\n"
                line = ''
              else
                output = output + line[0,offset + 1].strip + "\n"
                line = line[offset + 1, line.size - offset]
              end
            end
            output = output + line
          else
            output = output + line
          end
        }
        return output
      end
    end
  end

end
