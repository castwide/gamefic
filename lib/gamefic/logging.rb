# frozen_string_literal: true

require 'logger'

module Gamefic
  module Logging
    module_function

    # @return [Logger]
    def logger
      @@logger ||= select_logger.tap do |l|
        l.formatter = proc { |sev, _dt, _prog, msg| "[#{sev}] #{msg}\n"}
      end
    end

    private

    def select_logger
      if RUBY_ENGINE == 'opal'
        Logger.new(STDERR)
      else
        Logger.new(STDERR, level: Logger::WARN)
      end
    end
  end

  def self.logger
    Logging.logger
  end
end
