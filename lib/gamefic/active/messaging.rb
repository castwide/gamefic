# frozen_string_literal: true

module Gamefic
  module Active
    # A module for active entities that provides a default Messenger with
    # a few shortcuts.
    #
    module Messaging
      # @return [Messenger]
      def messenger
        @messenger ||= Messenger.new
      end

      # Send a message to the entity.
      #
      # This method will automatically wrap the message in HTML paragraphs.
      # To send a message without paragraph formatting, use #stream instead.
      #
      # @param message [String]
      def tell(message)
        messenger.tell message
      end

      # Send a message to the entity as raw text.
      #
      # Unlike #tell, this method will not wrap the message in HTML paragraphs.
      #
      # @param message [String]
      def stream(message)
        messenger.stream message
      end

      # @return [String]
      def messages
        messenger.messages
      end

      # Create a temporary buffer while yielding the given block and return the
      # buffered text.
      #
      # @return [String]
      def buffer &block
        messenger.buffer(&block)
      end

      # Clear the current buffer.
      #
      # @return [String] The buffer's messages
      def flush
        messenger.flush
      end
    end
  end
end
