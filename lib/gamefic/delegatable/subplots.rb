module Gamefic
  module Delegatable
    module Subplots
      # The hash of data that was used to initialize the subplot.
      #
      # @return [Hash]
      attr_reader :config

      # The subplot's host.
      #
      # @return [Host]
      def host
        @host ||= Host.new(@plot)
      end

      def persist klass, **args
        host.make klass, *args
      end

      def conclude
        rulebook.events.run_conclude_blocks
        players.each { |p| exeunt p }
        entities.each { |e| destroy e }
      end

      # Start a new subplot based on the provided class.
      #
      # @note A subplot's host is always the base plot, regardless of whether
      #   it was branched from another subplot.
      #
      # @param subplot_class [Class<Gamefic::Subplot>] The Subplot class
      # @param introduce [Gamefic::Actor, Array<Gamefic::Actor>, nil] Players to introduce
      # @param config [Hash] Subplot configuration
      # @return [Gamefic::Subplot]
      def branch subplot_class = Gamefic::Subplot, introduce: nil, **config
        @plot.branch subplot_class, introduce: introduce, **config
      end
    end
  end
end
