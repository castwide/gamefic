module Gamefic
  # Create and restore plot snapshots.
  #
  class Plot
    class Darkroom
      # @return [Gamefic::Plot]
      attr_reader :plot

      def initialize plot
        @plot = plot
      end

      # Create a snapshot of the plot.
      #
      # @return [Hash]
      def save reduce: false
        result = {
          # entities: plot.entities.map(&:to_serial),
          'elements' => Gamefic::Index.serials,
          'players' => plot.players.map(&:to_serial),
          'theater_instance_variables' => plot.theater.serialize_instance_variables,
          # 'subplots' => plot.subplots.map(&:to_serial),
          'subplots' => plot.subplots.map { |s| serialize_subplot(s) },
          'metadata' => plot.metadata
        }
      end

      # Restore a snapshot.
      #
      # @param snapshot [Hash]
      def restore snapshot
        Gamefic::Index.elements.map(&:destroy)
        Gamefic::Index.unserialize snapshot['elements']
        plot.entities.clear
        Gamefic::Index.elements.each_with_index do |e, i|
          plot.entities.push e
        end

        snapshot['theater_instance_variables'].each_pair do |k, s|
          v = Gamefic::Index.from_serial(s)
          next if v == "#<UNKNOWN>"
          plot.theater.instance_variable_set(k, v)
        end

        snapshot['subplots'].each { |s| unserialize_subplot(s) }
      end

      private

      def namespace_to_constant string
        space = Object
        string.split('::').each do |part|
          space = space.const_get(part)
        end
        space
      end

      def is_scene_class?(v)
        if v.kind_of?(Class)
          s = v
          until s.nil?
            return true if s == Gamefic::Scene::Base
            s = s.superclass
          end
          false
        else
          false
        end
      end

      def serialize_subplot s
        {
          'class' => s.class.to_s,
          'entities' => s.entities.map(&:to_serial),
          'instance_variables' => s.serialize_instance_variables,
          'theater_instance_variables' => s.theater.serialize_instance_variables
        }
      end

      def unserialize_subplot s
        cls = namespace_to_constant(s['class'])
        # sp = cls.allocate
        sp = cls.new(plot)
        s['instance_variables'].each_pair do |k, v|
          next if v == "#<UNKNOWN>"
          sp.instance_variable_set(k, Gamefic::Index.from_serial(v))
        end
        s['theater_instance_variables'].each_pair do |k, v|
          next if v == "#<UNKNOWN>"
          sp.theater.instance_variable_set(k, Gamefic::Index.from_serial(v))
        end
        plot.subplots.push sp
        sp
      end
    end
  end
end
