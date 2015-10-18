require 'gamefic'

module Gamefic::Sdk
  module Debug
    class Action < Gamefic::Action
      attr_reader :source_location
      def initialize(story, command, *queries, &proc)
        super
        @executed = false
        caller.each { |c|
          if c.end_with?(":in `stage'")
            @source_location = c[0..-12]
            break 
          end
        }
      end
      def execute *args
        super
        @executed = true
      end
      def executed?
        @executed
      end
      def standard?
        return false if source_location.nil?
        source_location.start_with?(Gamefic::Sdk::GLOBAL_IMPORT_PATH)
      end
    end
  end
end
