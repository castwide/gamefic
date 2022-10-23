module Gamefic
  module Query
    class External < Base
      # @param container [Plot, Subplot, Array]
      def initialize container, *args
        super(*args)
        @container = container
      end

      def context_from subject
        Set.new
           .merge(container_entities)
           .merge(container_subplots_for(@container, subject))
           .to_a
      end

      private

      # @return [Array<Entity>]
      def container_entities
        if @container.is_a?(World::Entities)
          @container.entities
        elsif @container.is_a?(Enumerable)
          @container
        else
          raise ArgumentError, "Unable to derive entities from #{@container}"
        end
      end

      # @return [Array<Entity>]
      def container_subplots_for container, subject
        return [] unless container.is_a?(Plot::Host)
        container.subplots_featuring(subject).flat_map do |subplot|
          subplot.entities + container_subplots_for(subplot, subject)
        end
      end
    end
  end
end
