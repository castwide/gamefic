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
      def save
        index = plot.static + plot.players
        plot.to_serial(index)
        {
          'program' => {}, # @todo Metadata for version control, etc.
          'index' => index.map do |i|
            if i.is_a?(Gamefic::Serialize)
              {
                'class' => i.class.to_s,
                'ivars' => i.serialize_instance_variables(index)
              }
            else
              i.to_serial(index)
            end
          end
        }
      end

      # Restore a snapshot.
      #
      # @param snapshot [Hash]
      def restore snapshot
        # @todo Use `program` for verification

        plot.subplots.each(&:conclude)
        plot.subplots.clear

        index = plot.static + plot.players
        snapshot['index'].each_with_index do |obj, idx|
          next if index[idx]
          elematch = obj['class'].match(/^#<ELE_([\d]+)>$/)
          if elematch
            klass = index[elematch[1].to_i]
          else
            klass = Gamefic::Serialize.string_to_constant(obj['class'])
          end
          index.push klass.allocate
        end

        snapshot['index'].each_with_index do |obj, idx|
          if index[idx].class.to_s != obj['class']
            STDERR.puts "MISMATCH: #{index[idx].class} is not #{obj['class']}"
            STDERR.puts obj.inspect
          end
          obj['ivars'].each_pair do |k, v|
            next if k == '@subplots'
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
            plot.subplots.push index[idx]
          end
        end
      end
    end
  end
end
