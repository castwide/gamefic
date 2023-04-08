require 'gamefic/plot'

module Gamefic
  # Subplots are disposable plots that run inside a parent plot. They can be
  # started and concluded at any time during the parent plot's runtime.
  #
  class Subplot < Assembly
    # The host plot.
    #
    # @return [Plot]
    attr_reader :plot

    # A hash of data that was used to initialize the subplot.
    #
    # @return [Hash]
    attr_reader :config

    # @param plot [Gamefic::Plot]
    # @param introduce [Gamefic::Actor, Array<Gamefic::Actor>, nil]
    # @param config [Hash]
    def initialize plot, introduce: nil, **config
      @plot = plot
      @config = config
      super()
      [introduce].compact.flatten.each { |pl| self.introduce pl }
    end

    def players
      @players ||= []
    end

    def ready
      scenebook.ready_blocks.each(&:call)
      players.each { |plyr| scenebook.run_player_ready_blocks plyr }
    end

    def update
      players.each do |plyr|
        scenebook.player_update_blocks.each { |blk| blk.call plyr }
      end
      scenebook.update_blocks.each(&:call)
    end

    def conclude
      players.each { |p| exeunt p }
      entities.each { |e| entities_safe_delete e }
    end

    def concluded?
      players.empty?
    end

    # Subclasses can override this method to handle additional configuration
    # options.
    #
    def configure **config; end

    def inspect
      "#<#{self.class}>"
    end
  end
end
