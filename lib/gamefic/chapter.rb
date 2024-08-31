# frozen_string_literal: true

module Gamefic
  class Chapter
    extend Scriptable

    include Scriptable::Actions
    include Scriptable::Events
    include Scriptable::Proxy
    include Scriptable::Queries
    include Scriptable::Scenes

    # @return [Plot]
    attr_reader :plot

    # @param plot [Plot]
    def initialize plot
      @plot = plot
      self.class.included_blocks.select(&:seed?).each { |blk| Stage.run self, &blk.code }
    end

    def rulebook
      plot.rulebook
    end

    def make klass, **opts
      plot.make klass, **opts
    end

    def hydrate
      rulebook.script self
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
