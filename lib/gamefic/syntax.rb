module Gamefic
  # Syntaxes provide rules for matching input patterns to existing responses.
  # Common uses are to provide synonyms for response verbs and allow for
  # variations in sentence structure.
  #
  # The template and command patterns use words beginning with a colon (e.g.,
  # `:thing`) to identify phrases that should be tokenized into arguments.
  #
  # @example All of these syntaxes will translate input into a command of the
  #   form "look thing container"
  #
  #     Syntax.new('examine :thing in :container', 'look :thing :container')
  #     Syntax.new('look at :thing inside :container', 'look :thing :container')
  #     Syntax.new('search :container for :thing', 'look :thing :container')
  #
  class Syntax
    # The pattern that matching input is expected to follow.
    #
    # @return [String]
    attr_reader :template

    # The pattern that will be used to tokenize the input into a command.
    #
    # @return [String]
    attr_reader :command

    # A symbol for the first word in the template. Used by playbooks to
    # classify groups of related syntaxes.
    #
    # @example
    #   syntax = Syntax.new('examine :thing', 'look :thing')
    #   syntax.synonym #=> :examine
    #
    # @return [Symbol]
    attr_reader :synonym

    # The response verb to which the command will be translated.
    #
    # @return [Symbol]
    attr_reader :verb

    # The number of words in the template. Playbooks use word counts to sort
    # syntaxes in descending order of precision.
    #
    # @return [Integer]
    attr_reader :word_count

    def initialize template, command
      words = template.keywords
      @word_count = words.length
      command_words = command.keywords
      @verb = nil
      if words[0][0] == ':'
        @word_count -= 1
      else
        @synonym = words[0].to_sym
        @verb = command_words[0].to_sym
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
            tokens.push '([\w\W\s\S]*?)'
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
      @regexp = Regexp.new("^#{tokens.join(' ')}$", Regexp::IGNORECASE)
    end

    # Convert a String into a Command.
    #
    # @param text [String]
    # @return [Command, nil]
    def tokenize text
      m = text&.match(@regexp)
      return nil if m.nil?

      arguments = []
      b = @verb.nil? ? 0 : 1
      xverb = @verb
      @replace.to_s.keywords[b..-1].each { |r|
        if r.match(/^\{\$[0-9]+\}$/)
          arguments.push m[r[2..-2].to_i]
        elsif arguments.empty? && xverb.nil?
          xverb = r.to_sym
        else
          arguments.push r
        end
      }
      Command.new xverb, arguments
    end

    # Determine if the specified text matches the syntax's expected pattern.
    #
    # @param text [String]
    # @return [Boolean]
    def accept? text
      !!text.match(@regexp)
    end

    # Get a signature that identifies the form of the Syntax.
    # Signatures are used to compare Syntaxes to each other.
    #
    def signature
      [@regexp, @replace]
    end

    def ==(other)
      return false unless other.is_a?(Syntax)
      signature == other.signature
    end

    def eql?(other)
      self == other
    end

    def hash
      signature.hash
    end

    # Tokenize an array of commands from the specified text. The resulting
    # array is in descending order of precision, i.e., most to least matched
    # tokens.
    #
    # @param text [String] The text to tokenize.
    # @param syntaxes [Array<Syntax>] The syntaxes to use.
    # @return [Array<Command>] The tokenized commands.
    def self.tokenize text, syntaxes
      syntaxes
        .map { |syn| syn.tokenize(text) }
        .compact
        .sort do |a, b|
          if a.verb == b.verb
            b.arguments.length <=> a.arguments.length
          else
            b.verb.to_s <=> a.verb.to_s
          end
        end
    end
  end
end
