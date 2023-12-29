# frozen_string_literal: true

module Gamefic
  # Message formatting and buffering.
  #
  class Messenger
    def initialize
      @buffers = ['']
    end

    # Create a temporary buffer while yielding the given block and return the
    # buffered text.
    #
    # @return [String]
    def buffer
      @buffers.push('')
      yield if block_given?
      @buffers.pop
    end

    # Add a formatted message to the current buffer.
    #
    # This method will automatically wrap the message in HTML paragraphs.
    # To send a message without formatting, use #stream instead.
    #
    # @param message [String, #to_s]
    # @return [String] The messages in the current buffer
    def tell(message)
      @buffers.push(@buffers.pop + format(message.to_s))
              .last
    end

    # Add a raw text message to the current buffer.
    #
    # Unlike #tell, this method will not wrap the message in HTML paragraphs.
    #
    # @param message [String, #to_s]
    # @return [String] The messages in the current buffer
    def stream(message)
      @buffers.push(@buffers.pop + message.to_s)
              .last
    end

    # Get the currently buffered messages.
    #
    # @return [String]
    def messages
      @buffers.last
    end

    # Clear the buffered messages.
    #
    # @return [String] The flushed message
    def flush
      @buffers.pop.tap { @buffers.push '' }
    end

    def format(message)
      "<p>#{message.strip}</p>"
        .gsub(/[ \t\r]*\n[ \t\r]*\n[ \t\r]*/, "</p><p>")
        .gsub(/[ \t]*\n[ \t]*/, ' ')
        .gsub(/<p>\s*<p>/, '<p>')
        .gsub(%r{</p>\s*</p>}, '</p>')
    end
  end
end
