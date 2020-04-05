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
            klass = namespace_to_constant(obj['class'])
          end
          index.push klass.allocate
        end
        snapshot.each_with_index do |obj, idx|
          if index[idx].class.to_s != obj['class']
            STDERR.puts "MISMATCH: #{index[idx].class} is not #{obj['class']}"
            STDERR.puts obj.inspect
          end
          obj['ivars'].each_pair do |k, v|
            uns = v.from_serial(index)
            next if uns == "#<UNKNOWN>"
            index[idx].instance_variable_set(k, uns)
          end
          if index[idx].is_a?(Gamefic::Subplot)
            index[idx].extend Gamefic::Scriptable
            index[idx].instance_variable_set(:@theater, nil)
            index[idx].send(:run_scripts)
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
    end
  end
end
