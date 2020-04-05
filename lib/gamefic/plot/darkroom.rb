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
        index = plot.static + plot.players
        plot.to_serial(index)
        index.map do |i|
          {
            'class' => i.class.to_s,
            'ivars' => i.serialize_instance_variables(index)
          }
        end
      end

      # Restore a snapshot.
      #
      # @param snapshot [Hash]
      def restore snapshot
        index = plot.static + plot.players
        snapshot.each_with_index do |obj, idx|
          next if index[idx]
          elematch = obj['class'].match(/^#<ELE_([\d]+)>$/)
          if elematch
            klass = index[elematch[1].to_i]
          else
            klass = eval(obj['class'])
          end
          index.push klass.allocate
        end
        snapshot.each_with_index do |obj, idx|
          if index[idx].class.to_s != obj['class']
            STDERR.puts "MISMATCH: #{index[idx].class} is not #{obj['class']}"
            STDERR.puts obj.inspect
          end
          if index[idx].is_a?(Gamefic::Subplot)
            more = obj['ivars']['@more'].from_serial(index)
            index[idx].instance_variable_set(:@plot, index[0])
            index[idx].configure more
            index[idx].send(:run_scripts)
          end
          obj['ivars'].each_pair do |k, v|
            uns = v.from_serial(index)
            next if uns == "#<UNKNOWN>"
            index[idx].instance_variable_set(k, uns)
          end
          if index[idx].is_a?(Gamefic::Subplot)
            index[idx].players.each do |pl|
              pl.playbooks.push index[idx].playbook unless pl.playbooks.include?(index[idx].playbook)
            end
            index[idx].instance_variable_set(:@static, [index[idx]] + index[idx].scene_classes + index[idx].entities)
          end
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
