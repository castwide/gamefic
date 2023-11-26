# frozen_string_literal: true

require 'logger'

module Gamefic
  module Logging
    module_function

    # @return [Logger]
    def logger
      Gamefic.logger
    end
  end

  class << self
    def logger
      @logger ||= select_logger.tap do |l|
        l.formatter = proc { |sev, _dt, _prog, msg| "[#{sev}] #{msg}\n"}
      end
    end

    private

    def select_logger
      # We use #tap here because `Logger.new(STDERR, level: Logger::WARN)`
      # fails in Opal
      Logger.new(STDERR).tap { |log| log.level = Logger::WARN }
    end
  end
end
