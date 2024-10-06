# frozen_string_literal: true

require 'gamefic/scanner/result'
require 'gamefic/scanner/base'
require 'gamefic/scanner/strict'
require 'gamefic/scanner/fuzzy'
require 'gamefic/scanner/nesting'
require 'gamefic/scanner/fuzzy_nesting'
require 'gamefic/scanner/nuanced'
require 'gamefic/scanner/nuanced_nesting'

module Gamefic
  # A module for matching objects to tokens.
  #
  module Scanner
    DEFAULT_PROCESSORS = [Nesting, Strict, FuzzyNesting, Fuzzy, NuancedNesting, Nuanced].freeze

    # Scan entities against a token.
    #
    # @param selection [Array<Entity>]
    # @param token [String]
    # @return [Result]
    def self.scan selection, token
      result = nil
      processors.each do |processor|
        result = processor.scan(selection, token)
        break unless result.matched.empty?
      end
      result
    end

    # Select the scanner processors to use in entity queries. Each processor
    # will be used in order until one of them returns matches. The default
    # processor list is `DEFAULT_PROCESSORS`.
    #
    # Processor classes should be in order from most to least strict rules
    # for matching tokens to entities.
    #
    # @param klasses [Array<Class<Base>>]
    # @return [Array<Class<Base>>]
    def self.use *klasses
      processors.replace klasses.flatten
    end

    # @return [Array<Class<Base>>]
    def self.processors
      @processors ||= []
    end

    def self.strictness processor
      (processors.length - (processors.find_index(processor) || processors.length)) * 100
    end

    use DEFAULT_PROCESSORS
  end
end
