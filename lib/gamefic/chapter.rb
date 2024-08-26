# frozen_string_literal: true

module Gamefic
  class Chapter
    extend Scriptable

    include Scriptable::Actions
    include Scriptable::Events
    include Scriptable::Proxy
    include Scriptable::Queries
    include Scriptable::Scenes

    def initialize narrative
      @narrative = narrative
      self.class.included_blocks.select(&:seed?).each { |blk| Stage.run self, &blk.code }
    end

    def rulebook
      @narrative.rulebook
    end

    def make klass, **opts
      @narrative.make klass, **opts
    end

    def hydrate
      rulebook.script self
    end
  end
end
