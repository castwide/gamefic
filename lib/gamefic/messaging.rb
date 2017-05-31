module Gamefic
  module Messaging
    # Send a message to the entity.
    # This method will automatically wrap the message in HTML paragraphs.
    # To send a message without paragraph formatting, use #stream instead.
    #
    # @param message [String]
    def tell(message)
      message = "<p>#{message.strip}</p>"
      # This method uses String#gsub instead of String#gsub! for
      # compatibility with Opal.
      message = message.gsub(/[ \t\r]*\n[ \t\r]*\n[ \t\r]*/, '</p><p>')
      message = message.gsub(/[ \t]*\n[ \t]*/, ' ')
      p_set_messages messages + message
    end

    # Send a message to the Character as raw text.
    # Unlike #tell, this method will not wrap the message in HTML paragraphs.
    #
    # @param message [String]
    def stream(message)
      p_set_messages messages + message.strip
    end

    # @return [String]
    def messages
      @messages ||= ''
    end
    
    def output
      messages
    end

    def flush
      p_set_messages '' unless messages.empty?
    end

    private

    def p_set_messages str
      @messages = str
    end
  end
end
