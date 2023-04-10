require 'gamefic/plot'

module Gamefic
  # Subplots are disposable plots that run inside a parent plot. They can be
  # started and concluded at any time during the parent plot's runtime.
  #
  class Subplot < Narrative
    module ScriptMethods
      include Scriptable::Actions
      include Scriptable::Configs
      include Scriptable::Entities
      include Scriptable::Queries
      include Scriptable::Scenes
    end

    include ScriptMethods

    # The host plot.
    #
    # @return [Plot]
    attr_reader :plot

    # @param plot [Gamefic::Plot]
    # @param introduce [Gamefic::Actor, Array<Gamefic::Actor>, nil]
    # @param config [Hash]
    def initialize plot, introduce: nil, **config
      @plot = plot
      @config = config.freeze
      super(ScriptMethods.public_instance_methods)
      [introduce].compact.flatten.each { |pl| self.introduce pl }
    end

    def players
      @players ||= []
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
