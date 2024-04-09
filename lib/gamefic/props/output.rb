# frozen_string_literal: true

module Gamefic
  module Props
    # A container for output sent to players with a hash interface for custom
    # data.
    #
    class Output
      def initialize **data
        @raw_data = {
          messages: '',
          options: [],
          queue: [],
          scene: {},
          prompt: ''
        }
        merge! data
      end

      # @return [String]
      def messages
        raw_data[:messages]
      end

      # @return [Array<String>]
      def options
        raw_data[:options]
      end

      # @return [Array<String>]
      def queue
        raw_data[:queue]
      end

      # @todo Should this be a concrete class?
      # @return [Hash]
      def scene
        raw_data[:scene]
      end

      # @return [String]
      def prompt
        raw_data[:prompt]
      end

      def last_input
        raw_data[:last_input]
      end

      def last_prompt
        raw_data[:last_prompt]
      end

      def [] key
        raw_data[key]
      end

      def []= key, value
        raw_data[key] = value
      end

      # @return [Hash]
      def to_hash
        raw_data.dup
      end

      def to_json _ = nil
        raw_data.to_json
      end

      def merge! data
        data.each { |key, val| self[key] = val }
      end

      def replace data
        raw_data.replace data
      end

      private

      attr_reader :raw_data
    end
  end
end
