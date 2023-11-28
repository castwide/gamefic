# frozen_string_literal: true

module Gamefic
  # An object that acts as a delegate between entity instances in a plot and
  # entity references in the plot's theater.
  #
  # Proxies allow scripts to retain static references to entities across plot
  # restorations. When a plot gets restored from a snapshot, the variables in
  # the script that reference entities should point correctly to the restored
  # entities.
  #
  # Proxies and entities are designed to be interchangeable. Authors should
  # not need to care whether a variable points to a proxy or an entity.
  #
  class Proxy
    # @return [Narrative]
    attr_reader :narrative

    # @return [Integer]
    attr_reader :index

    # @param host [Narrative]
    # @param index [Integer]
    def initialize narrative, index
      @narrative = narrative
      @index = index
      freeze
    end

    # @return [Gamefic::Entity]
    def entity
      narrative.entities[index]
    end
  end
end
