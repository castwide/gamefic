# frozen_string_literal: true

require 'gamefic/scanner/result'
require 'gamefic/scanner/default'
require 'gamefic/scanner/nesting'

module Gamefic
  # A module for matching objects to tokens.
  #
  module Scanner

    # Scan entities against a token.
    #
    # @param selection [Array<Entity>, String, Regexp]
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

    # @param selection [Array<Entity>, String, Regexp]
    # @param token [String]
    # @return [Result]
    def self.strict selection, token
      return Result.new(selection, token, '', token) unless selection.is_a?(Array)

      scan_strict_or_fuzzy(selection, token, :select_strict)
    end

    def self.use *klasses
      processors.replace klasses
    end

    class << self
      private

      def processors
        @processors ||= [Nesting, Default]
      end
    end
  end
end
