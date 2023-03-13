module Gamefic
  # Create and restore plot snapshots.
  #
  class Plot
    class Darkroom
      # @return [Plot]
      attr_reader :plot

      # @param plot [Plot]
      def initialize plot
        @plot = plot
      end

      # Create a snapshot of the plot.
      #
      # @return [Hash]
      def save
        {
          'program' => {}, # @todo Metadata for version control, etc.
          'index' => index.map { |obj| serialize_indexed(obj) }
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
          if index[idx].is_a?(Gamefic::Subplot)
            index[idx].send(:theater).instance_variable_set(:@host, index[idx])
            index[idx].send(:run_scripts)
          end
          obj['ivars'].each_pair do |k, v|
            next if k == '@subplots' #|| k == '@children'
            uns = v.from_serial(index)
            next if uns == "#<UNKNOWN>"
            if index[idx].is_a?(Gamefic::Subplot)
              next if index[idx].instance_variable_get(k)
              index[idx].instance_variable_set(k, uns) #unless index[idx].is_a?(Gamefic::Subplot)
            else
              index[idx].instance_variable_set(k, uns) #unless index[idx].is_a?(Gamefic::Subplot)
            end
          end
          if index[idx].is_a?(Gamefic::Subplot)
            index[idx].players.each do |pl|
              pl.playbooks.push index[idx].playbook unless pl.playbooks.include?(index[idx].playbook)
            end
            plot.subplots.push index[idx]
          end
        end
      end

      private

      def index
        @index ||= begin
          populate_full_index_from(plot)
          Set.new(plot.static + plot.players).merge(full_index).to_a
        end
      end

      def full_index
        @full_index ||= Set.new
      end

      def populate_full_index_from(object)
        return if full_index.include?(object)
        if object.is_a?(Array) || object.is_a?(Set)
          object.each { |ele| populate_full_index_from(ele) }
        elsif object.is_a?(Hash)
          object.each_pair do |k, v|
            populate_full_index_from(k)
            populate_full_index_from(v)
          end
        else
          if object.is_a?(Gamefic::Serialize)
            full_index.add object unless object.is_a?(Module) && object.name
            object.instance_variables.each do |v|
              next if object.class.excluded_from_serial.include?(v)
              populate_full_index_from(object.instance_variable_get(v))
            end
          else
            object.instance_variables.each do |v|
              populate_full_index_from(object.instance_variable_get(v))
            end
          end
        end
      end

      def serialize_indexed object
        if object.is_a?(Gamefic::Serialize)
          # Serialized objects in the index should be a full serialization.
          # Serialize#to_serial rturns a reference to the indexed object.
          {
            'class' => object.class.to_s,
            'ivars' => object.serialize_instance_variables(index)
          }
        else
          object.to_serial(index)
        end
      end
    end
  end
end
