# frozen_string_literal: true

# require 'gamefic/syntax/template'

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
    PARAM_REGEXP = /^:[a-z0-9_]+$/i.freeze

    # @return [String]
    attr_reader :template

    # @return [Array<String>]
    attr_reader :params

    # The pattern that will be used to tokenize the input into a command.
    #
    # @return [String]
    attr_reader :command

    # The response verb to which the command will be translated.
    #
    # @example
    #   syntax = Syntax.new('examine :thing', 'look :thing')
    #   syntax.verb #=> :look
    #
    # @return [Symbol]
    attr_reader :verb

    # @param template [String]
    # @param command [String]
    def initialize(template, command)
      @template = template.normalize
      @params = @template.keywords.select { |word| word.start_with?(':') }
      @command = command.normalize
      @verb = Syntax.literal_or_nil(@command.keywords[0])
      @replace = parse_replace
    end

    # A symbol for the first word in the template. Used by rulebooks to
    # classify groups of related syntaxes.
    #
    # @example
    #   syntax = Syntax.new('examine :thing', 'look :thing')
    #   syntax.synonym #=> :examine
    #
    # @return [Symbol]
    def synonym
      @synonym ||= Syntax.literal_or_nil(template.keywords.first)
    end

    # @return [Regexp]
    def regexp
      @regexp ||= Regexp.new("^#{make_tokens.join(' ')}$", Regexp::IGNORECASE)
    end

    # Convert a String into a Command.
    #
    # @param text [String]
    # @return [Expression, nil]
    def tokenize(text)
      match = text&.match(regexp)
      return nil unless match

      Expression.new(verb, match_to_args(match))
    end

    # Determine if the specified text matches the syntax's expected pattern.
    #
    # @param text [String]
    # @return [Boolean]
    def match?(text)
      !!text.match(regexp)
    end
    alias accept? match?

    # Get a signature that identifies the form of the Syntax.
    # Signatures are used to compare Syntaxes to each other.
    #
    def signature
      [regexp, replace]
    end

    def ==(other)
      signature == other&.signature
    end

    # Tokenize an array of commands from the specified text. The resulting
    # array is in descending order of precision, i.e., most to least matched
    # tokens.
    #
    # @param text [String] The text to tokenize.
    # @param syntaxes [Array<Syntax>] The syntaxes to use.
    # @return [Array<Expression>] The tokenized expressions.
    def self.tokenize(text, syntaxes)
      syntaxes
        .map { |syn| syn.tokenize(text) }
        .compact
        .uniq { |exp| [exp.verb, exp.tokens] }
        .sort_by { |exp| [-exp.tokens.compact.length] }
    end

    # @param string [String]
    # @return [Symbol, nil]
    def self.literal_or_nil(string)
      string.start_with?(':') ? nil : string.to_sym
    end

    # Split a syntax template by words and expressions.
    #
    # @param template [String]
    # @return [Array<String>]
    def self.split(template)
      parens = 0
      result = template.normalize.chars.each.with_object(['']) do |char, result|
        parens = parse_token(char, parens, result)
      end
      raise "Unbalanced parentheses in syntax '#{template}'" unless parens.zero?

      result.pop if result.last.empty?

      result
    end

    class << self
      private

      # @param char [String]
      # @param parens [Integer]
      # @param result [Array<String>]
      def parse_token(char, parens, result)
        case char
        when /[()]/
          parens += (char == '(' ? 1 : -1)
        when /\s/
          return parens if result.last.empty?

          if parens.positive?
            result.push(result.pop + char)
          else
            result.push ''
          end
        else
          result.push(result.pop + char)
        end

        parens
      end
    end

    private

    # @return [String]
    attr_reader :replace

    def parse_replace
      command.keywords.map do |word|
        next word unless word.start_with?(':')

        index = params.index(word) ||
                raise(ArgumentError, "syntax command references undefined parameter `#{word}`")
        "{$#{index + 1}}"
      end.join(' ')
    end

    def match_to_args(match)
      start = replace.start_with?('{') ? 0 : 1
      replace.keywords[start..].map do |str|
        str.match?(/^\{\$[0-9]+\}$/) ? match[str[2..-2].to_i] : str
      end
    end

    # @return [Array<String>]
    def make_tokens
      Syntax.split(template).map.with_index do |word, idx|
        next "(?:\\b#{word.gsub('|', '|\\b')})" if word.include?('|')
        next word unless word.match?(PARAM_REGEXP)
        next nil if idx.positive? && template.keywords[idx - 1].match?(PARAM_REGEXP)

        '([\w\W\s\S]*?)'
      end.compact
    end
  end
end
