module Gamefic
  module Scriptable
    module Subplots
      # The hash of data that was used to initialize the subplot.
      #
      # @return [Hash]
      attr_reader :config

      # The subplot's host.
      #
      # @return [Host]
      attr_reader :host

      def conclude
        scenebook.run_conclude_blocks
        players.each { |p| exeunt p }
        entities.each { |e| destroy e }
      end
    end
  end
end
