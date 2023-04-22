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
    # @return [Plot, Subplot]
    attr_reader :host

    # @return [Integer]
    attr_reader :index

    # @param host [Plot, Subplot]
    # @param index [Integer]
    def initialize host, index
      @host = host
      @index = index
      freeze
    end

    # @return [Gamefic::Entity]
    def entity
      host.entities[index]
    end

    def self.index(host, entity)
      index = host.entities.find_index(entity)
      raise 'Entity could not be proxied' unless index

      Proxy.new(host, index)
    end
  end
end
