# frozen_string_literal: true

module Gamefic
  # The plot is the central narrative. It provides a script interface with
  # methods for creating entities, actions, scenes, and hooks.
  #
  class Plot < Narrative
    attr_reader :chapters

    def initialize
      super
      @chapters = self.class.appended_chapters.map { |chap| chap.new(self) }
    end

    def included_scripts
      (super + chapters.flat_map(&:included_scripts)).uniq
    end

    def uncast(actor)
      subplots.each { |sp| sp.uncast actor }
      super
    end

    # Get an array of all the current subplots.
    #
    # @return [Array<Subplot>]
    def subplots
      @subplots ||= []
    end

    # Start a new subplot based on the provided class.
    #
    # @param subplot_class [Class<Gamefic::Subplot>] The Subplot class
    # @param introduce [Gamefic::Actor, Array<Gamefic::Actor>] Players to introduce
    # @param config [Hash] Subplot configuration
    # @return [Gamefic::Subplot]
    def branch subplot_class = Gamefic::Subplot, introduce: [], **config
      subplot_class.new(self, introduce: introduce, **config)
                   .tap { |sub| subplots.push sub }
    end

    def save
      Snapshot.save self
    end

    def inspect
      "#<#{self.class}>"
    end

    def self.append(chapter)
      appended_chapters.add chapter
    end

    def self.appended_chapters
      @appended_chapters ||= Set.new
    end

    def self.restore(data)
      Snapshot.restore data
    end

    def turn
      super
      subplots.each(&:conclude) if concluding?
      chapters.delete_if(&:concluding?)
      subplots.delete_if(&:concluding?)
    end

    def ready_blocks
      (super + subplots.flat_map(&:ready_blocks))
    end

    def update_blocks
      (super + subplots.flat_map(&:update_blocks))
    end

    def player_output_blocks
      (super + subplots.flat_map(&:player_output_blocks))
    end
  end
end
