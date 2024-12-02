# frozen_string_literal: true

module Gamefic
  module Props
    # A container for output sent to players with a hash interface for custom
    # data.
    #
    class Output
      READER_METHODS = %i[messages options queue scene prompt last_prompt last_input].freeze
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

      # @!attribute [rw] messages
      #   A text message to be displayed at the start of a scene.
      #
      #   @return [String]

      # @!attribute [rw] options
      #   An array of options to be presented to the player, e.g., in a
      #   MultipleChoice scene.
      #
      #   @return [Array<String>]

      # @!attribute [rw] queue
      #   An array of commands waiting to be executed.
      #
      #   @return [Array<String>]

      # @!attribute [rw] scene
      #   A hash containing the scene's :name and :type.
      #
      #   @return [Hash]

      # @!attribute [rw] [prompt]
      #   The input prompt to be displayed to the player.
      #
      #   @return [String]

      # @!attribute [rw] last_input
      #   The input received from the player in the previous scene.
      #
      #   @return [String, nil]

      # @!attribute [rw] last_prompt
      #   The input prompt from the previous scene.
      #
      #   @return [String, nil]

      # @param key [Symbol]
      def [](key)
        raw_data[key]
      end

      # @param key [Symbol]
      # @param value [Object]
      def []=(key, value)
        raw_data[key] = value
      end

      # @return [Hash]
      def to_hash
        raw_data.dup
      end

      def to_json(_ = nil)
        raw_data.to_json
      end

      def merge!(data)
        data.each { |key, val| self[key] = val }
      end

      def replace(data)
        raw_data.replace data
      end

      def freeze
        raw_data.freeze
        super
      end

      def method_missing method, *args
        return raw_data[method] if READER_METHODS.include?(method)

        return raw_data[method.to_s[0..-2].to_sym] = args.first if WRITER_METHODS.include?(method)

        super
      end

      def respond_to_missing?(method, _with_private = false)
        READER_METHODS.include?(method) || WRITER_METHODS.include?(method)
      end

      EMPTY = new.freeze
    end
  end
end
