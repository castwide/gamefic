module Gamefic
  # Create and restore plot snapshots.
  #
  class Plot
    class Darkroom2
      # @return [Gamefic::Plot]
      attr_reader :plot

      def initialize plot
        @plot = plot
      end

      # Create a snapshot of the plot.
      #
      # @return [Hash]
      def save reduce: false
        index = plot.static + plot.players
        # result = {
        #   'elements' => Gamefic::Index.serials,
        #   'entities' => plot.entities.map(&:to_serial),
        #   'players' => plot.players.map(&:to_serial),
        #   'theater_instance_variables' => plot.theater.serialize_instance_variables,
        #   'subplots' => plot.subplots.reject(&:concluded?).map { |s| serialize_subplot(s) },
        #   'metadata' => plot.metadata
        # }
        plot.to_serial(index)
      end

      # Restore a snapshot.
      #
      # @param snapshot [Hash]
      # def restore snapshot
      #   Gamefic::Index.elements.map(&:destroy)
      #   Gamefic::Index.unserialize snapshot['elements']
      #   plot.entities.clear
      #   snapshot['entities'].each do |ser|
      #     plot.entities.push Index.from_serial(ser)
      #   end

      #   snapshot['theater_instance_variables'].each_pair do |k, s|
      #     v = Gamefic::Index.from_serial(s)
      #     next if v == "#<UNKNOWN>"
      #     plot.theater.instance_variable_set(k, v)
      #   end

      #   snapshot['subplots'].each { |s| unserialize_subplot(s) }
      # end

      def restore snapshot
        index = plot.static + plot.players
        plot.instance_variables.each do |k|
          # current = Gamefic::Serialize.instances
          plot.instance_variable_set(k, snapshot['ivars'][k.to_s].from_serial(index))
          # index.concat(Gamefic::Serialize.instances - current)
        end
      end

      private

      def namespace_to_constant string
        space = Object
        string.split('::').each do |part|
          space = space.const_get(part)
        end
        space
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
        sp = cls.allocate
        sp.instance_variable_set(:@plot, plot)
        s['entities'].each do |e|
          sp.entities.push Gamefic::Index.from_serial(e)
        end
        s['instance_variables'].each_pair do |k, v|
          next if v == "#<UNKNOWN>"
          sp.instance_variable_set(k, Gamefic::Index.from_serial(v))
        end
        s['theater_instance_variables'].each_pair do |k, v|
          next if v == "#<UNKNOWN>"
          sp.theater.instance_variable_set(k, Gamefic::Index.from_serial(v))
        end
        plot.subplots.push sp
        sp.send(:run_scripts)
        # @todo Assuming one player
        if plot.players.first
          sp.players.push plot.players.first
          plot.players.first.playbooks.push sp.playbook unless plot.players.first.playbooks.include?(sp.playbook)
        end
        sp
      end
    end
  end
end
