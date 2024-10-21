# frozen_string_literal: true

require 'gamefic/plot'

module Gamefic
  # Subplots are disposable plots that run inside a parent plot. They can be
  # started and concluded at any time during the parent plot's runtime.
  #
  class Subplot < Narrative
    # @return [Hash]
    attr_reader :config

    # @return [Plot]
    attr_reader :plot

    # @param plot [Gamefic::Plot]
    # @param introduce [Gamefic::Actor, Array<Gamefic::Actor>, nil]
    # @param config [Hash]
    def initialize plot, introduce: [], **config
      @plot = plot
      @config = config
      configure
      @config.freeze
      super()
      @concluded = false
      [introduce].flatten.each { |plyr| self.introduce plyr }
    end

    def seeds
      super - plot.seeds
    end

    def self.persist!
      @persistent = true
    end

    def self.persistent?
      @persistent ||= false
    end

    def persistent?
      self.class.persistent?
    end

    def conclude
      players.each do |plyr|
        player_conclude_blocks.each { |blk| blk[plyr] }
        uncast plyr
      end
      entities.each { |ent| destroy ent }
      @concluded = true
    end

    # Make an entity that persists in the subplot's parent plot.
    #
    # @see Plot#make
    #
    def persist klass, **args
      plot.make klass, *args
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
    def branch subplot_class = Gamefic::Subplot, introduce: [], **config
      plot.branch subplot_class, introduce: introduce, **config
    end

    # Subclasses can override this method to handle additional configuration
    # options.
    #
    def configure; end

    def concluding?
      return super unless persistent?

      @concluded
    end

    def introduce player
      @concluded ? player : super
    end

    def prepare(...)
      super || plot.prepare(...)
    end

    def inspect
      "#<#{self.class}>"
    end

    class << self
      def config
        Proxy::Config.new
      end
    end
  end
end
