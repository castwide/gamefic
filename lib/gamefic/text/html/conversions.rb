require 'gamefic/text/ansi'
require 'gamefic/text/html'
require 'io/console'

module Gamefic

  module Text::Html::Conversions
    include Gamefic::Text

    def self.html_to_ansi text, wrap: true, width: nil
      return '' if text.strip == ''
      output = ''
      begin
        doc = Html.parse("<body>#{text.gsub(/\r/, '').strip}</body>")
        output = AnsiFormatter.new.format(doc) + Ansi.graphics_mode(Ansi::Code::Attribute::NORMAL)
        output = Html.decode(output)
      rescue REXML::ParseException => e
        output = Html.encode(text) + "\n\n"
      end
      calc_width = width || size[0]
      if calc_width.nil? or !wrap
        output
      else
        terminalize(output, calc_width - 1)
      end
    end

    def self.html_to_text text, wrap: true, width: nil
      text = html_to_ansi text, wrap: wrap, width: width
      text.gsub(/\e\[([;\d]+)?m/, '').gsub(/\n +\n/, "\n\n")
    end

    class AnsiNode
      include Gamefic::Text::Ansi::Code
      attr_accessor :parent
      
      def render
      end

      def in_block?
        p = parent
        while !p.nil?
          return true if p.kind_of?(BlockNode)
          p = p.parent
        end
        false
      end
    end
    private_constant :AnsiNode

    class TextNode < AnsiNode
      @@prev_format = nil
      attr_reader :text, :format
      def initialize text, format
        @text = text
        @format = format
      end
      def render
        return @text if format.include?(Extra::PRE)
        index = parent.children.index(self)
        if index > 0
          prev = parent.children[index - 1]
          if prev.kind_of?(TextNode) and prev.format == format
            if prev.text.match(/ $/)
              return @text.lstrip
            else
              return @text
            end
          end
        end
        if @@prev_format == format
          @text
        else
          @prev_format = format
          Gamefic::Text::Ansi.graphics_mode(*format) + @text
        end
      end
    end
    private_constant :TextNode

    class ElementNode < AnsiNode
      def children
        @children ||= []
      end
      def append child
        children.push child
        child.parent = self
      end
    end
    private_constant :ElementNode

    class BlockNode < ElementNode
      def render
        output = ''
        children.each { |c|
          output += c.render
        }
        output = "\n" + output.strip unless in_block?
        output
      end
    end
    private_constant :BlockNode

    class InlineNode < ElementNode
      def render
        output = ''
        children.each { |c|
          output += c.render
          output += "\n" if c.kind_of?(BlockNode)
        }
        output
      end
    end
    private_constant :InlineNode

    class BreakNode < ElementNode
      def render
        output = ''
        children.each { |c|
          output += c.render
        }
        output + "\n"
      end
    end
    private_constant :BreakNode

    class AnsiFormatter
      include Gamefic::Text::Ansi::Code
      def format document
        @document = document
        @ansi_root = InlineNode.new
        @list_index = []
        format_recursively @document.root, @ansi_root, [Attribute::NORMAL]
        output = @ansi_root.render
        output += (@ansi_root.children.last.kind_of?(BlockNode) ? "\n" : "")
      end

      def format_recursively element, ansi_node, stack
        if element.is_a?(REXML::Text)
          append_text element, ansi_node, stack
        else
          current = []
          case element.name
          when 'b', 'strong', 'em'
            current.push Attribute::BOLD
            format_children element, ansi_node, stack + current
          when 'i', 'u'
            current.push Attribute::UNDERSCORE
            format_children element, ansi_node, stack + current
          when 'h1', 'h2', 'h3', 'h4', 'h5'
            current.push Attribute::BOLD, Extra::UPPERCASE
            format_paragraph element, ansi_node, stack + current
          when 'p'
            format_paragraph element, ansi_node, stack
          when 'ol', 'ul'
            @list_index.push 0
            format_paragraph element, ansi_node, stack
            @list_index.pop
          when 'li'
            format_list_item element, ansi_node, stack
          when 'pre'
            current.push Extra::PRE
            format_children element, ansi_node, stack + current
          when 'br'
            ansi_node.append TextNode.new("\n", stack + [Extra::PRE])
          else
            format_children element, ansi_node, stack
          end
        end
      end

      def append_text element, ansi_node, stack
        text = element.to_s
        text.gsub!(/[\s]+/, ' ') unless stack.include?(Extra::PRE)
        text.upcase! if stack.include?(Extra::UPPERCASE)
        ansi_node.append TextNode.new(text, stack)
      end

      def format_children element, node, stack
        element.each { |e|
          format_recursively e, node, stack
        }
      end

      def format_paragraph element, node, stack
        paragraph = BlockNode.new
        node.append paragraph
        format_children element, paragraph, stack
      end

      def format_list_item element, node, stack
        i = 0
        unless @list_index.empty?
          @list_index[-1] = @list_index[-1] + 1
          i = @list_index[-1] 
        end
        b = BreakNode.new
        node.append b
        if element.parent.name == 'ol'
          b.append TextNode.new("#{i}. ", stack)
        else
          b.append TextNode.new("* ", stack)
        end
        format_children element, b, stack
      end
    end
    private_constant :AnsiFormatter

    def self.terminalize string, max_length
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
      output
    end

    def self.size
      begin
        return STDOUT.winsize.reverse
      rescue
        return [nil,nil]
      end
    end
  end

end
