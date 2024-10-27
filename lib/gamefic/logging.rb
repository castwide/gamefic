# frozen_string_literal: true

require 'logger'

module Gamefic
  # A simple logger.
  #
  module Logging
    module_function

    # @return [Logger]
    def logger
      Gamefic.logger
    end
  end

  class << self
    def logger
      @logger ||= Logger.new($stderr).tap do |lggr|
        lggr.level = Logger::WARN
        lggr.formatter = proc { |sev, _dt, _prog, msg| "[#{sev}] #{msg}\n" }
      end
    end
  end
end
