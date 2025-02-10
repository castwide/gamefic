# frozen_string_literal: true

module Gamefic
  # The plot is the central narrative. It provides a script interface with
  # methods for creating entities, actions, scenes, and hooks.
  #
  class Plot < Narrative
    # @return [Array<Chapter>]
    attr_reader :chapters

    def initialize
      super
      @chapters = self.class.appended_chapter_map.map { |chap, config| chap.new(self, **unproxy(config)) }
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

    def inspect
      "#<#{self.class}>"
    end

    def self.append(chapter, **config)
      Gamefic.logger.warn "Overwriting existing chapter #{chapter}" if appended_chapter_map.key?(chapter)

      appended_chapter_map[chapter] = config
    end

    def self.appended_chapter_map
      @appended_chapter_map ||= {}
    end

    # Complete a game turn.
    #
    # In addition to running its own applicable conclude blocks, the Plot class
    # will also handle conclude blocks for its chapters and subplots.
    #
    # @return [void]
    def turn
      super
      subplots.each(&:conclude) if concluding?
      chapters.delete_if(&:concluding?)
      subplots.delete_if(&:concluding?)
    end

    def ready_blocks
      super + subplots.flat_map(&:ready_blocks)
    end

    def update_blocks
      super + subplots.flat_map(&:update_blocks)
    end

    def player_output_blocks
      super + subplots.flat_map(&:player_output_blocks)
    end

    def responses
      super + chapters.flat_map(&:responses)
    end

    def responses_for(*verbs)
      super + chapters.flat_map { |chap| chap.responses_for(*verbs) }
    end

    def syntaxes
      super + chapters.flat_map(&:syntaxes)
    end

    def find_and_bind(symbol)
      super + chapters.flat_map { |chap| chap.find_and_bind(symbol) }
    end
  end
end
