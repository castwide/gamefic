# frozen_string_literal: true

require 'gamefic/scanner/result'
require 'gamefic/scanner/default'
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

    def self.processors
      @processors ||= [Nesting, Default, Fuzzy]
    end
  end
end
