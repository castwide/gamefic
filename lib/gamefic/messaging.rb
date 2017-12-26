module Gamefic
  module Messaging
    # Send a message to the entity.
    # This method will automatically wrap the message in HTML paragraphs.
    # To send a message without paragraph formatting, use #stream instead.
    #
    # @param message [String]
    def tell(message)
      p_set_messages messages + format(message)
    end

    # Send a message to the Character as raw text.
    # Unlike #tell, this method will not wrap the message in HTML paragraphs.
    #
    # @param message [String]
    def stream(message)
      p_set_messages messages + message.strip
    end

    # Get all the currently buffered messages consolidated in a single string.
    #
    # @return [String]
    def messages
      @messages ||= ''
    end

    # Alias for #messages.
    #
    # @return [String]
    def output
      messages
    end

    # Clear the buffered messages.
    #
    def flush
      p_set_messages '' unless messages.empty?
    end

    private

    def format message
      "<p>#{message.strip}</p>".gsub(/[ \t\r]*\n[ \t\r]*\n[ \t\r]*/, "</p>\n\n<p>").gsub(/[ \t]*\n[ \t]*/, ' ')
    end

    def p_set_messages str
      @messages = str
    end
  end
end
