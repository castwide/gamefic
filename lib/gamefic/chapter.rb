# frozen_string_literal: true

module Gamefic
  class Chapter
    extend Scriptable

    def initialize narrative
      @narrative = narrative
      self.class.included_blocks.select(&:seed?).each { |blk| Stage.run self, &blk.code }
      hydrate
    end

    def make klass, **opts
      @narrative.make klass, **opts
    end

    def hydrate
      # narrative.rulebook.append self
    end
  end
end
