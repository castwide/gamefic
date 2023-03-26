require 'json'

module Gamefic
  # Create and restore plot snapshots.
  #
  class Plot
    class Darkroom
      include Logging

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
        indexed = index(plot)
        result = {
          'program' => plot.metadata,
          'index' => indexed.map { |obj| serialize_indexed(obj, indexed) },
          'configs' => plot.subplots.map { |subplot| serialize_indexed(subplot.more.merge({ next_cue: subplot.next_cue }), indexed) },
          'subplots' => plot.subplots.map { |subplot| serialize_indexed(subplot, indexed) }
        }
        result
      end

      # Restore a snapshot.
      #
      # @param snapshot [Hash]
      def restore snapshot
        raise LoadError, "Unable to verify snapshot" unless snapshot['program'].to_json == plot.metadata.to_json

        plot.subplots.each(&:conclude)
        plot.subplots.clear

        snapshot['subplots'].each_with_index do |serial, idx|
          more = snapshot['configs'][idx].from_serial(index(plot))
          klass = Gamefic::Serialize.string_to_constant(serial['class'])
          subplot = klass.new(plot, **more)
          plot.subplots.push subplot
          subplot.players.each { |pl| pl.playbooks.push subplot.playbook }
        end
        index = hydrate(plot, snapshot['index'])
        rebuild index, snapshot['index']
        plot.subplots.each do |subplot|
          subplot.players.each { |pl| pl.playbooks.push subplot.playbook }
        end
      end

      private

      def index plot
        full_index = Set.new
        populate_full_index_from(plot, full_index)
        all = plot.static + plot.players
        plot.subplots.each { |sp| all.concat sp.static }
        Set.new(all).merge(full_index).to_a
      end

      # @param object [Object]
      # @param full_index [Set]
      def populate_full_index_from(object, full_index)
        return if full_index.include?(object)
        if object.is_a?(Array) || object.is_a?(Set)
          object.each { |ele| populate_full_index_from(ele, full_index) }
        elsif object.is_a?(Hash)
          object.each_pair do |k, v|
            populate_full_index_from(k, full_index)
            populate_full_index_from(v, full_index)
          end
        else
          if object.is_a?(Gamefic::Serialize)
            full_index.add object unless object.is_a?(Module) && object.name
            object.instance_variables.each do |v|
              next if Serialize.exclude?(object, v)

              populate_full_index_from(object.instance_variable_get(v), full_index)
            end
          else
            object.instance_variables.each do |v|
              populate_full_index_from(object.instance_variable_get(v), full_index)
            end
          end
        end
      end

      def serialize_indexed object, indexed
        if object.is_a?(Gamefic::Serialize)
          # Serialized objects in the index should be a full serialization.
          # Serialize#to_serial rturns a reference to the indexed object.
          {
            'class' => object.class.to_s,
            'ivars' => object.serialize_instance_variables(indexed)
          }
        else
          object.to_serial(indexed)
        end
      end

      # @param plot [Plot]
      # @return [Array]
      def hydrate plot, serial
        index = index(plot)
        serial.each_with_index do |obj, idx|
          next if index[idx]
          elematch = obj['class'].match(/^#<ELE_([\d]+)>$/)
          if elematch
            klass = index[elematch[1].to_i]
          else
            klass = Gamefic::Serialize.string_to_constant(obj['class'])
          end
          if klass == Theater
            index.push klass.new(plot)
          else
            index.push klass.allocate
          end
        end
        index
      end

      def rebuild index, serial
        serial.each_with_index do |obj, idx|
          # @todo This warning hits false positives
          if !index[idx].is_a?(Class) && index[idx].class.to_s != obj['class']
            logger.warn "Mismatch: #{obj['class']} in snapshot expected to be #{index[idx].class}"
          end
          obj['ivars'].each_pair do |k, v|
            uns = v.from_serial(index)
            next if uns == "#<UNKNOWN>"
            ext = index[idx].instance_variable_get(k)
            setter = "#{k.to_s[1..-1]}="
            if index[idx].respond_to?(setter)
              index[idx].send(setter, uns)
            else
              index[idx].instance_variable_set(k, uns) #unless index[idx].is_a?(Gamefic::Subplot)
            end
          end
        end
      end
    end
  end
end
