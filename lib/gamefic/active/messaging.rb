module Gamefic
  module Active
    # A module for active entities that provides a default Messenger with
    # a few shortcuts.
    #
    module Messaging
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

      def messages
        messenger.messages
      end

      def buffer &block
        messenger.buffer(&block)
      end

      def flush
        messenger.flush
      end
    end
  end
end
