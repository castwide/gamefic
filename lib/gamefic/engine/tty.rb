require 'gamefic/engine'
require 'thread'

module Gamefic

  module Tty
    class TerminalThread
      # original detect_terminal_size method by cldwalker (https://github.com/cldwalker) (https://github.com/cldwalker/hirb/blob/master/lib/hirb/util.rb)
      # modified to return an array of nil values instead of nil
      def detect_terminal_size
        if (ENV['COLUMNS'] =~ /^\d+$/) && (ENV['LINES'] =~ /^\d+$/)
          [ENV['COLUMNS'].to_i, ENV['LINES'].to_i]
        elsif (RUBY_PLATFORM =~ /java/ || (!STDIN.tty? && ENV['TERM']))
          [`tput cols`.to_i, `tput lines`.to_i]
        elsif STDIN.tty?
          `stty size`.scan(/\d+/).map { |s| s.to_i }.reverse
        else
          [nil,nil]
        end
      rescue
        [nil,nil]
      end
      def send(text)
        @semaphore.synchronize {
          @output.push [:text, text.to_s]
        }      
      end
      def initialize
        @output = Array.new
        @semaphore = Mutex.new
        @thread = Thread.new {
          while true
            @semaphore.synchronize {
              @size = detect_terminal_size
              while @output.length > 0
                data = @output.shift
                case data[0]
                  when :html
                    # TODO: Support HTML and/or Markdown
                    print data[1]
                  else
                    print data[1]
                end
              end
            }
          end
        }
      end
      def size
        result = nil
        @semaphore.synchronize {
          result = @size
        }
        result
      end
      def running?
        (@thread.stop? == false)
      end
    end
    @@terminal_thread = TerminalThread.new
    def self.terminal_thread
      @@terminal_thread
    end
    class Engine < Gamefic::Engine
      def post_initialize
        @user = Tty::User.new @plot
        Tty::terminal_thread.send "\n"
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
        Tty::terminal_thread.size
      end
      def send data
        Tty::terminal_thread.send("#{terminalize(data, size[0])}\n\n")
      end
      def select(prompt)
        Tty::terminal_thread.send "#{terminalize(prompt, size[0])}"
        line = STDIN.gets
        Tty::terminal_thread.send "\n"
        @queue.push line.strip
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
