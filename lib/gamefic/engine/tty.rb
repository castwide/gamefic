require 'gamefic/engine'
begin
  require 'io/console'
rescue LoadError
  puts "This version of Ruby does not support io/console. Text may not wrap correctly."
  if RUBY_VERSION.split('.')[0].to_i < 2
    puts "It is recommended that you upgrade to Ruby 2.0.0 or higher."
  end
end

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
      def size
        if STDOUT.respond_to?(:winsize)
          return STDOUT.winsize.reverse
        end
        return [nil,nil]
      end
      def send data
        # TODO: This is a quick and dirty way to strip HTML tags.
        # A parser would be a better solution.
        #data.gsub!(/<[a-z]+[^>]*>/i, "")
        #data.gsub!(/<\/[^>]*>/, "")
        return if data.strip == ''
        width = size[0]
        if width.nil?
          super "#{data}\n"
        else
          super "#{terminalize(data, width - 1)}\n\n"
        end
      end
      def select(prompt)
        super
        print "\n"
      end
      def terminalize string, max_length
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
