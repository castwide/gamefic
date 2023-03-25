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
          'plot' => indexed.map { |obj| serialize_indexed(obj, indexed) },
          'configs' => plot.subplots.map { |subplot| serialize_indexed(subplot.more.merge({ next_cue: subplot.next_cue }), indexed) },
          'subplots' => plot.subplots.map do |subplot|
            indexed = index(subplot)
            indexed.map { |obj| serialize_indexed(obj, indexed) }
          end
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

        plot.entities.each { |ent| ent.parent = nil }

        index = hydrate(plot, snapshot['plot'])
        rebuild index, snapshot['plot']

        # reparent_entities plot

        restore_subplots index, snapshot['configs'], snapshot['subplots']
      end

      private

      def restore_subplots top_index, configs, serials
        mores = configs.map { |cfg| cfg.from_serial(top_index) }

        serials.each_with_index do |serial, idx|
          klass = Gamefic::Serialize.string_to_constant(serial.first['class'])
          subplot = klass.new(plot, **mores[idx])
          subplot.entities.each { |ent| ent.parent = nil }
          index = hydrate(subplot, serial)
          rebuild index, serial
          # next if subplot.concluded?
          plot.subplots.push subplot
          fakes = subplot.players.clone
          subplot.players.replace(subplot.players
                                         .map do |fake|
                                          found = plot.players.find { |real| real.inspect == fake.inspect }
                                          raise LoadError, "Could not restore player" unless found
                                          found
                                         end
                                         .compact)
          subplot.entities.each do |ent|
            idx = fakes.index(ent.parent)
            ent.parent = subplot.players[idx] if idx
          end
          subplot.players.each do |pl|
            pl.playbooks.push subplot.playbook unless pl.playbooks.include?(subplot.playbook)
          end

          # reparent_entities subplot
        end
      end

      def index plot
        full_index = Set.new
        populate_full_index_from(plot, full_index)
        Set.new(plot.static + plot.players).merge(full_index).to_a
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

      # @param plot [Plot, Subplot]
      # @return [Array]
      def hydrate plot, serial
        index = plot.static + plot.players
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
          if index[idx].class.to_s != obj['class']
            logger.warn "Mismatch: #{obj['class']} in snapshot expected to be #{index[idx].class}"
          end
          obj['ivars'].each_pair do |k, v|
            uns = v.from_serial(index)
            next if uns == "#<UNKNOWN>"
            ext = index[idx].instance_variable_get(k)
            if ext.is_a?(Gamefic::Serialize)
              if ext.class != uns.class
                logger.warn "Mismatch in #{index[idx].class} #{k}: found #{ext.class}, expected #{uns.class}"
                setter = "#{k.to_s[1..-1]}="
                if index[idx].respond_to?(setter)
                  index[idx].send(setter, uns)
                else
                  index[idx].instance_variable_set(k, uns) #unless index[idx].is_a?(Gamefic::Subplot)
                end
              else
                uns.instance_variables.each do |iv|
                  ext.instance_variable_set iv, uns.instance_variable_get(iv)
                end
              end
            else
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

      def reparent_entities plot
        # plot.entities.each do |ent|
        #   cur = ent.parent
        #   ent.parent = nil
        #   ent.parent = cur
        # end
      end
    end
  end
end
