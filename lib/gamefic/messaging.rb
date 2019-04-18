module Gamefic
  module Messaging
    # Send a message to the entity.
    # This method will automatically wrap the message in HTML paragraphs.
    # To send a message without paragraph formatting, use #stream instead.
    #
    # @param message [String]
    def tell(message)
      messages.concat format(message)
    end

    # Send a message to the Character as raw text.
    # Unlike #tell, this method will not wrap the message in HTML paragraphs.
    #
    # @param message [String]
    def stream(message)
      messages.concat message.strip
    end

    # Get all the currently buffered messages consolidated in a single string.
    #
    # @return [String]
    def messages
      @messages ||= ''
    end
    alias output messages

    # Clear the buffered messages.
    #
    def flush
      messages.clear
    end

    private

    def format message
      "<p>#{message.strip}</p>"
        .gsub(/[ \t\r]*\n[ \t\r]*\n[ \t\r]*/, "</p><p>")
        .gsub(/[ \t]*\n[ \t]*/, ' ')
        .gsub(/<p>[\s]*<p>/, '<p>')
        .gsub(/<\/p>[\s]*<\/p>/, '</p>')
    end
  end
end
