# frozen_string_literal: true

require 'gamefic/syntax/template'

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
    # @return [Template]
    attr_reader :template

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

    # @param template [Template, String]
    # @param command [String]
    def initialize template, command
      @template = Template.to_template(template)
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
      template.verb
    end

    # Convert a String into a Command.
    #
    # @param text [String]
    # @return [Expression, nil]
    def tokenize text
      match = text&.match(template.regexp)
      return nil unless match

      Expression.new(verb, match_to_args(match))
    end

    # Determine if the specified text matches the syntax's expected pattern.
    #
    # @param text [String]
    # @return [Boolean]
    def accept? text
      !!text.match(template.regexp)
    end

    # Get a signature that identifies the form of the Syntax.
    # Signatures are used to compare Syntaxes to each other.
    #
    def signature
      [template.regexp, replace]
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
    def self.tokenize text, syntaxes
      syntaxes
        .map { |syn| syn.tokenize(text) }
        .compact
        .sort { |syn, other_syn| syn.compare other_syn }
    end

    # Compare two syntaxes for the purpose of ordering them in rulebooks.
    #
    def compare other
      template.compare other.template
    end

    # @param string [String]
    # @return [String, nil]
    def self.literal_or_nil string
      string.start_with?(':') ? nil : string.to_sym
    end

    private

    # @return [String]
    attr_reader :replace

    def parse_replace
      command.keywords.map do |word|
        next word unless word.start_with?(':')

        index = template.params.index(word) ||
                raise(ArgumentError, "syntax command references undefined parameter `#{word}`")
        "{$#{index + 1}}"
      end.join(' ')
    end

    def match_to_args match
      start = replace.start_with?('{') ? 0 : 1
      replace.keywords[start..].map do |str|
        str.match?(/^\{\$[0-9]+\}$/) ? match[str[2..-2].to_i] : str
      end
    end
  end
end
