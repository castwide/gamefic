# frozen_string_literal: true

module Gamefic
  # Chapters are plot extensions that manage their own namespaces. Authors can
  # use them to encapsulate related content in a separate object instead of
  # adding the required instance variables, methods, and attributes to the
  # plot.
  #
  # Chapters are similar to subplots with a few important exceptions:
  # * Chapters persist for the duration of the plot.
  # * Players do not need to be introduced to a chapter.
  # * Scripts in chapters apply to the parent plot's rulebook.
  # * Using `make` to create an entity in a chapter adds it to the parent
  #   plot's entity list.
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
  class Chapter
    extend Scriptable

    include Scriptable::Actions
    include Scriptable::Events
    include Scriptable::Proxies
    include Scriptable::Queries
    include Scriptable::Scenes

    # @return [Plot]
    attr_reader :plot

    # @param plot [Plot]
    def initialize plot
      @plot = plot
    end

    def included_blocks
      self.class.included_blocks - plot.included_blocks
    end

    def seed
      included_blocks.select(&:seed?).each { |blk| Stage.run self, &blk.code }
    end

    def script
      included_blocks.select(&:script?).each { |blk| Stage.run self, &blk.code }
    end

    def rulebook
      plot.rulebook
    end

    def make klass, **opts
      plot.make klass, **opts
    end

    def entities
      plot.entities
    end

    def players
      plot.players
    end

    def destroy entity
      plot.destroy entity
    end

    def pick description
      plot.pick description
    end

    def pick! description
      plot.pick! description
    end
  end
end
