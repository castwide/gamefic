# frozen_string_literal: true

require 'gamefic/scanner/result'
require 'gamefic/scanner/base'
require 'gamefic/scanner/strict'
require 'gamefic/scanner/fuzzy'
require 'gamefic/scanner/nesting'

module Gamefic
  # A module for matching objects to tokens.
  #
  module Scanner
    # Scan entities against a token.
    #
    # @param selection [Array<Entity>]
    # @param token [String]
    # @return [Result]
    def self.scan selection, token
      result = nil
      processors.each do |processor|
        result = processor.new(selection, token).scan
        break unless result.matched.empty?
      end
      result
    end

    def self.use *klasses
      processors.replace klasses
    end

    # @return [Array<Class<Default>>]
    def self.processors
      @processors ||= [Nesting, Strict, Fuzzy]
    end
  end
end
