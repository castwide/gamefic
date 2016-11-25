require 'gamefic/engine'
require 'rexml/document'
require 'gamefic/ansi'
require 'gamefic/html'
require 'json'

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
      def save filename, snapshot
        data = snapshot.merge(:metadata => @character.plot.metadata)
        json = JSON.generate data
        if json.nil?
          @character.tell "Nothing to save."
        end
        if filename.nil?
          stream.select "Enter the filename to save:"
          filename = stream.queue.pop
        end
        if filename != ''
          File.open(filename, 'w') do |f|
            f.write json
          end
          @character.tell "Game saved."
        end
      end
      def restore filename
        if filename.nil?
          stream.select "Enter the filename to restore:"
          filename = stream.queue.pop
        end
        if filename != ''
          if File.exists?(filename)
            data = JSON.parse File.read(filename), symbolize_names: true
            if (data[:metadata] != @character.plot.metadata)
              @character.tell "The save file is not compatible with this version of the game."
            else
              return data
            end
          else
            @character.tell "File \"#{filename}\" not found."
          end
        end
        nil
      end
    end
    class UserStream < Gamefic::UserStream
      include Ansi
      include Ansi::Code
      def initialize
        super
      end
      def size
        begin
          return STDOUT.winsize.reverse
        rescue
          return [nil,nil]
        end
      end
      def flush
        data = @buffer.clone
        @buffer.clear
        return if data.strip == ''
        output = ''
        begin
          doc = Html.parse("<body>#{data}</body>")
          format_recursively doc
          texts = REXML::XPath.match(doc, './/text()')
          output = texts.join('').gsub(/&apos;/, "'").gsub(/&quot;/, '"').gsub(/&lt;/, '<').gsub(/&gt;/, '>')
          output += Ansi.graphics_mode(Attribute::NORMAL)
          output = Html::decode(output)
        rescue REXML::ParseException => e
          puts e.inspect
          output = Html.encode(data) + "\n\n"
        end
        output.gsub!(/(\n\n)+/, "\n\n")
        width = size[0]
        if width.nil?
          output
        else
          "#{terminalize(output, width - 1)}"
        end
      end
      def select(prompt)
        super
        print "\n"
      end
      def has_code?(fmt, code)
        if fmt.kind_of?(Array)
          return fmt.flatten.include?(code)
        end
        return fmt == code
      end
      
      private
      
      def format_recursively(top, stack = nil)
        ol_index = 1
        stack ||= [Attribute::NORMAL]
        top.elements.each { |element|
          formats = [Attribute::NORMAL]
          classes = element.attribute('class').to_s.split(' ')
          if classes.include?('hint')
            formats.push Foreground::YELLOW
          end
          case element.name
            when 'strong', 'b'
              formats.push Attribute::BOLD
            when 'em', 'i', 'u'
              formats.push Attribute::UNDERSCORE
            when 'a'
              if element.attributes['rel'].to_s == 'gamefic'
                element.attributes['href'] = element.attributes['href'][5..-1]
                formats.push [Attribute::UNDERSCORE, Extra::COMMAND]
              else
                formats.push [Attribute::UNDERSCORE, Extra::HREF]
              end
            when 'li'
              if top.name == 'ol'
                element.text = "#{ol_index}. #{element.text}"
                ol_index += 1
              else
                element.text = "* #{element.text}"
              end
              formats.push [Extra::LINE]
            when 'img'
              formats.push [Extra::IGNORED]
            when 'p', 'ol', 'ul'
              formats.push Extra::BLOCK
            when 'nav'
              formats.push Extra::BLOCK
            when 'h1', 'h2', 'h3', 'h4', 'h5'
              formats.push [Attribute::BOLD, Extra::BLOCK, Extra::UPPERCASE]
            when 'kbd'
              formats.push [Foreground::GREEN]
          end
          if has_code?(stack, Extra::IGNORED)
            element.parent.delete_element(element)
          end
          stack.push formats
          if has_code?(stack, Extra::UPPERCASE)
            element.texts.each { |text|
              text.value.upcase!
            }
          end
          element.texts.each { |text|
            text.value = "#{Ansi.graphics_mode(*stack)}#{text.value}"
          }
          if has_code?(stack.last, Extra::IMAGE)
            element.text = "#{element.attribute('alt') ? element.attribute('alt') : '[Image]'}"
          end
          format_recursively element, stack
          if has_code?(stack.last, Extra::COMMAND)
            if element.attribute('data-command').to_s != ''
              tmp = stack.pop
              element.add_text "#{Ansi.graphics_mode(*stack)}"
              element.add_text " [#{element.attribute('data-command')}]"
              stack.push tmp
              element.add_text "#{Ansi.graphics_mode(*stack)}"
            end
          end
          if has_code?(stack.last, Extra::BLOCK)
            element.add_text("\n\n")
          elsif has_code?(stack.last, Extra::LINE)
            if !has_code?(stack[-2], Extra::BLOCK) || element != top.elements.to_a.last
              element.add_text("\n")
            end
          end
          if has_code?(stack.last, Extra::HREF)
            if element.attribute('href').to_s != "#"
              tmp = stack.pop
              element.add_text "#{Ansi.graphics_mode(*stack)}"
              element.add_text(" [#{element.attribute('href')}]")
              stack.push tmp
              element.add_text "#{Ansi.graphics_mode(*stack)}"
            end
          end
          if has_code?(stack.last, Extra::IMAGE)
            element.add_text(" [#{element.attribute('src')}]")
            if !has_code?(stack, Extra::BLOCK)
              element.add_text("\n\n")
            end
          end
          stack.pop
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
            output += string[i..end_of_seq]
            i = end_of_seq + 1
          elsif char == " "
            next_space = string.index(/[\s]/, i + 1)
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
        output #output.strip
      end
    end
  end

end
