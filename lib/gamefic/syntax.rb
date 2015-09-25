module Gamefic

  class Syntax
    autoload :Match, 'gamefic/syntax/match'
    attr_reader :token_count, :first_word, :verb, :template, :command
    @@phrase = '([\w\W\s\S]*?)'
    def initialize plot, template, *command
      command = command.join(' ')
      words = template.split_words
      @token_count = words.length
      command_words = command.split_words
      @verb = nil
      if words[0][0] == ':'
        @token_count -= 1
        @first_word = ''
      else
        @verb = command_words[0].to_sym if !command_words[0].nil?
        @first_word = words[0].to_s
      end
      @command = command_words.join(' ')
      @template = words.join(' ')
      tokens = []
      variable_tokens = []
      last_token_is_reg = false
      words.each { |w|
        if w.match(/^:[a-z0-9_]+$/i)
          variable_tokens.push w
          if last_token_is_reg
            next
          else
            tokens.push @@phrase
            last_token_is_reg = true
          end
        else
          tokens.push w
          last_token_is_reg = false
        end
      }
      subs = []
      index = 0
      command_words.each { |t|
        if t[0] == ':'
          index = variable_tokens.index(t) + 1
          subs.push "{$#{index}}"
        else
          subs.push t
        end
      }
      @replace = subs.join(' ')
      @regexp = Regexp.new("^#{tokens.join(' ')}$")
      if !plot.nil?
        plot.send :add_syntax, self
      end
    end
    def translate text
      m = text.match(@regexp)
      return nil if m.nil?
      arguments = []
      @replace.to_s.split_words.each { |r|
        if r.match(/^\{\$[0-9]+\}$/)
          arguments.push m[r[2..-2].to_i]
        else
          arguments.push r
        end
      }
      Syntax::Match.new @verb, arguments
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
