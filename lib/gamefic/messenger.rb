# frozen_string_literal: true

require 'stringio'

module Gamefic
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

    # Send a message to the entity.
    #
    # This method will automatically wrap the message in HTML paragraphs.
    # To send a message without paragraph formatting, use #stream instead.
    #
    # @param message [String]
    def tell(message)
      msg = @buffers.pop + format(message)
      @buffers.push msg
      msg
    end

    # Send a message to the Character as raw text.
    #
    # Unlike #tell, this method will not wrap the message in HTML paragraphs.
    #
    # @param message [String]
    def stream(message)
      msg = @buffers.pop + message
      @buffers.push msg
      msg
    end

    # Get all the currently buffered messages consolidated in a single string.
    #
    # @return [String]
    def messages
      @buffers.last
    end

    # Clear the buffered messages.
    #
    # @return [String] The flushed message
    def flush
      last = @buffers.pop
      @buffers.push ''
      last
    end

    def format message
      "<p>#{message.strip}</p>"
        .gsub(/[ \t\r]*\n[ \t\r]*\n[ \t\r]*/, "</p><p>")
        .gsub(/[ \t]*\n[ \t]*/, ' ')
        .gsub(/<p>\s*<p>/, '<p>')
        .gsub(%r{</p>\s*</p>}, '</p>')
    end
  end
end
