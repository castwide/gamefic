require 'gamefic/engine'
require 'rexml/document'
require 'gamefic/ansi'

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
      def ansi=(val)
        @stream.ansi = val
      end
      def ansi
        @stream.ansi
      end
    end
    class UserStream < Gamefic::UserStream
      include Ansi
      include Ansi::Code
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
        return if data.strip == ''
        #eol = ''
        #if data.start_with?(Ansi::NEL)
        #  data = data[Ansi::NEL.length..-1]
        #  eol = "\n\n"
        #end
        #width = size[0]
        #if width.nil?
        #  super "#{data}#{eol}"
        #else
        #  super "#{terminalize(data, width - 1)}#{eol}"
        #end
        doc = REXML::Document.new "<line>#{data}</line>"
        format_recursively doc, [Attribute::NORMAL]
        texts = REXML::XPath.match(doc, './/text()')
        output = texts.join('').gsub(/&apos;/, "'").gsub(/&quot;/, '"').gsub(/&lt;/, '<').gsub(/&gt;/, '>')
        width = size[0]
        if width.nil?
          super output
        else
          print "#{terminalize(output, width - 1)}"
        end
      end
      def select(prompt)
        super
        print "\n"
      end
      def has_code?(fmt, code)
        if fmt.kind_of?(Array)
          return fmt.include?(code)
        end
        return fmt == code
      end
      def format_recursively(top, stack)
        top.elements.each { |element|
          formatting = true
          case element.name
            when 'strong', 'b'
              stack.push Attribute::BOLD
            when 'em', 'i', 'u'
              stack.push Attribute::UNDERSCORE
            when 'a'
              stack.push [Attribute::UNDERSCORE, Foreground::CYAN, Extra::HREF]
            when 'img'
              stack.push [Extra::IMAGE, Attribute::UNDERSCORE, Foreground::CYAN]
            when 'p'
              stack.push Extra::BLOCK
            when 'h1'
              stack.push [Attribute::BOLD, Attribute::UNDERSCORE, Extra::BLOCK, Extra::UPPERCASE]
            when 'h1', 'h2', 'h3', 'h4', 'h5'
              stack.push [Attribute::BOLD, Extra::BLOCK, Extra::UPPERCASE]
            else
              formatting = false
          end
          if formatting
            if has_code?(stack.last, Extra::UPPERCASE)
              element.text = element.text.to_s.upcase
            end
            if has_code?(stack.last, Extra::IMAGE)
              element.text = "#{element.attribute('alt') ? element.attribute('alt') : '[Image]'}"
            end
            element.text = "#{Ansi.graphics_mode(*stack.flatten.that_are_not(Custom))}#{element.text}"
            format_recursively element, stack
            element.add_text "#{Ansi.graphics_mode(*stack[0..-2].flatten.that_are_not(Custom))}"
            if has_code?(stack.last, Extra::BLOCK)
              element.add_text("\n\n")
            end
            if has_code?(stack.last, Extra::HREF)
              element.add_text(" [#{element.attribute('href')}]")
            end
            if has_code?(stack.last, Extra::IMAGE)
              element.add_text(" [#{element.attribute('src')}]")
            end
            stack.pop
          else
            format_recursively element, stack
          end
        }
      end
      def terminalize string, max_length
        i = 0
        output = ''
        line_length = 0
        while i < string.length
          line_length += 1
          char = string[i,1]
          if char == "\e"
            # Right now, graphics modes are the only supported ANSI sequences.
            end_of_seq = string.index("m", i)
            # TODO: Check if we're permitting ANSI formatting
            output += string[i..end_of_seq]
            i = end_of_seq + 1
          elsif char == " "
            next_space = string.index(" ", i + 1)
            if !next_space.nil? and line_length + (next_space - i) > max_length
              output += "\n"
              line_length = 0
            else
              output += char
            end
            i += 1
          else
            if char == "\n"
              line_length = 0
            end
            output += char
            i += 1
          end
        end
        output
      end
    end
  end

end
