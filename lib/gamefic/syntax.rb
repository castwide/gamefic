module Gamefic

  class Syntax
    attr_reader :token_count, :first_word, :action, :template, :command
    @@phrase = '([a-z0-9\- ]*?)'
    def initialize plot, template, *command
      command = command.join(' ')
      words = template.split_words
      @token_count = words.length
      command_words = command.split_words
      if words[0][0] == ':'
        @token_count -= 1
        @action = nil
        @first_word = ''
      else
        @action = command_words[0].to_sym
        @first_word = words[0].to_s
      end
      @command = command_words.join(' ')
      words.each_index { |i|
        if words[i][0] != ':'
          #words[i][0] = Regexp.escape(words[i][0])
        end
      }
      @template = words.join(' ')
      index = 0
      @replace = @command
      reg_tmp = @template.gsub(/:[a-z0-9_]+/i) { |m|
        index += 1
        @replace = @replace.gsub(m, "{$#{index}}")
        @@phrase
      }
      @regexp = Regexp.new("^#{reg_tmp}$")
      if !plot.nil?
        plot.send :add_syntax, self
      end
    end
    def translate text
      m = text.match(@regexp)
      return nil if m.nil?
      result = []
      @replace.split_words.each { |r|
        if r.match(/^\{\$[0-9]+\}$/)
          result.push m[r[2..-2].to_i]
        else
          result.push r
        end
      }
      if @nil_action
        result.unshift nil
      else
        result[0] = @action
      end
      result
    end
    def signature
      [@regexp, @replace]
    end
    def ==(other)
      signature == other.signature
    end
    def self.match text, syntaxes
      matches = []
      syntaxes.each { |syntax|
        result = syntax.translate text
        matches.push(result) if !result.nil?
      }
      matches
    end
  end

end
