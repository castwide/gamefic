require 'gamefic/plot'

module Gamefic
  # Subplots are disposable plots that run inside a parent plot. They can be
  # started and concluded at any time during the parent plot's runtime.
  #
  class Subplot < Assembly
    # @return [Gamefic::Plot]
    attr_reader :plot

    # @return [Hash]
    attr_reader :more

    attr_reader :next_cue

    # @param plot [Gamefic::Plot]
    # @param introduce [Gamefic::Actor, nil]
    # @param next_cue [Class<Gamefic::Base>, nil]
    # @param more [Hash]
    def initialize plot, introduce: nil, next_cue: nil, **more
      # @plot = plot
      # @next_cue = next_cue
      # @concluded = false
      # @more = more.freeze
      # configure(**more)
      # run_scripts
      # self.introduce introduce unless introduce.nil?
      # theater
      # define_static
      @plot = plot
      run_scripts
      setup.entities.hydrate
      setup.scenes.hydrate
      setup.actions.hydrate
      default_scene && default_conclusion # Make sure they exist
      playbook.freeze
      scenebook.freeze
      self.introduce introduce if introduce
    end

    def run_scripts
      Gamefic.logger.warn "SHARE ME WITH PLOTS"
      self.class.blocks.each { |blk| stage &blk }
    end

    def players
      @players ||= []
    end

    def subplot
      self
    end

    def default_scene
      plot.default_scene
    end

    def default_conclusion
      plot.default_conclusion
    end

    # def cast cls, args = {}, &block
    #   ent = super
    #   ent.playbooks.push plot.playbook unless ent.playbooks.include?(plot.playbook)
    #   ent
    # end

    def conclude
      @concluded = true
      players.each { |p| exeunt p }
      entities.each { |e| entities_safe_delete e }
    end

    def concluded?
      @concluded
    end

    # Subclasses can override this method to handle additional configuration
    # options.
    #
    def configure **more; end

    def inspect
      "#<#{self.class}>"
    end
  end
end
