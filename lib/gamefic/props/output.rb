# frozen_string_literal: true

module Gamefic
  module Props
    # A container for output sent to players with a hash interface for custom
    # data.
    #
    class Output
      WRITER_METHODS = %i[messages= prompt= last_prompt= last_input=].freeze

      attr_reader :raw_data

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

      # A text message to be displayed at the start of a scene.
      #
      # @return [String]
      def messages
        raw_data[:messages]
      end

      # An array of options to be presented to the player, e.g., in a
      # MultipleChoice scene.
      #
      # @return [Array<String>]
      def options
        raw_data[:options]
      end

      # An array of commands waiting to be executed.
      #
      # @return [Array<String>]
      def queue
        raw_data[:queue]
      end

      # A hash containing the scene's :name and :type.
      #
      # @return [Hash]
      def scene
        raw_data[:scene]
      end

      # The input prompt to be displayed to the player.
      #
      # @return [String]
      def prompt
        raw_data[:prompt]
      end

      # The input received from the player in the previous scene.
      #
      def last_input
        raw_data[:last_input]
      end

      # The input prompt from the previous scene.
      #
      def last_prompt
        raw_data[:last_prompt]
      end

      # @param key [Symbol]
      def [] key
        raw_data[key]
      end

      # @param key [Symbol]
      # @param value [Object]
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

      def freeze
        raw_data.freeze
        super
      end

      def method_missing sym, arg
        return raw_data[sym.to_s[0..-2].to_sym] = arg if WRITER_METHODS.include?(sym)

        super
      end
    end
  end
end
