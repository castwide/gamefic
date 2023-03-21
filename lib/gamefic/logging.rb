# frozen_string_literal: true

require 'logger'

module Gamefic
  module Logging
    module_function

    # @return [Logger]
    def logger
      @logger ||= Logger.new(STDERR, level: Logger::DEBUG)
                        .tap do |l|
                          l.formatter = proc { |sev, _dt, _prog, msg| "[#{sev}] #{msg}\n"}
                        end
    end
  end
end
