# frozen_string_literal: true

require 'logger'

module Gamefic
  module Logging
    module_function

    # @return [Logger]
    def logger
      @@logger ||= Logger.new(STDERR, level: Logger::WARN)
                        .tap do |l|
                          l.formatter = proc { |sev, _dt, _prog, msg| "[#{sev}] #{msg}\n"}
                        end
    end
  end

  def self.logger
    Logging.logger
  end
end
