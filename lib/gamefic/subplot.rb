require 'gamefic/plot'
require 'securerandom'

module Gamefic
  # Subplots are disposable plots that run inside a parent plot. They can be
  # started and concluded at any time during the parent plot's runtime.
  #
  class Subplot < Narrative
    module ScriptMethods
      include Scriptable::Actions
      include Scriptable::Entities
      include Scriptable::Queries
      include Scriptable::Scenes
      include Scriptable::Subplots
    end

    include ScriptMethods

    # The host plot.
    #
    # @return [Plot]
    attr_reader :plot

    attr_reader :uuid

    # @param plot [Gamefic::Plot]
    # @param introduce [Gamefic::Actor, Array<Gamefic::Actor>, nil]
    # @param config [Hash]
    def initialize plot, introduce: nil, **config
      @plot = plot
      configure **config
      @config = config.freeze
      super(ScriptMethods)
      @uuid ||= SecureRandom.uuid
      [introduce].compact.flatten.each { |pl| self.introduce pl }
    end

    def ready
      super
      conclude if concluding?
    end

    def conclude
      scenebook.run_conclude_blocks
      players.each { |p| exeunt p }
      entities.each { |e| entities_safe_delete e }
    end

    # Subclasses can override this method to handle additional configuration
    # options.
    #
    def configure **config; end

    # @todo This is ugly. Necessary for the Open Cases Burglary subplot
    def subplot
      self
    end

    def inspect
      "#<#{self.class}>"
    end
  end
end
