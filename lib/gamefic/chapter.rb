# frozen_string_literal: true

module Gamefic
  # Chapters are plot extensions that manage their own namespaces. Authors can
  # use them to encapsulate related content in a separate object instead of
  # adding the required instance variables, methods, and attributes to the
  # plot.
  #
  # Chapters are similar to subplots with three important exceptions:
  # * Chapters normally persist for the duration of a plot.
  # * Players do not need to be introduced to a chapter.
  # * Chapters share their plot's entities, players, and rulebook.
  #
  # @example
  #   class MyChapter < Gamefic::Chapter
  #     seed do
  #       @thing = make Gamefic::Entity, name: 'chapter thing'
  #     end
  #   end
  #
  #   class MyPlot < Gamefic::Plot
  #     append MyChapter
  #   end
  #
  #   plot = MyPlot.new
  #   plot.entities                 #=> [<#Gamefic::Entity a chapter thing>]
  #   plot.instance_exec { @thing } #=> nil
  #
  class Chapter < Narrative
    # @return [Plot]
    attr_reader :plot

    # @param plot [Plot]
    def initialize(plot)
      @plot = plot
      # The plot is responsible for hydrating chapters
      super(hydrate: false)
    end

    def included_blocks
      self.class.included_blocks - plot.included_blocks
    end

    def rulebook
      plot.rulebook
    end

    def entity_vault
      plot.entity_vault
    end

    def player_vault
      plot.player_vault
    end
  end
end
