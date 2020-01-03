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

        # snapshot[:players].each_with do |p|
        # end
        # @todo Rebuild subplots
        # snapshot[:subplots].each do |s|
        #   cls = namespace_to_constant(s[:class])
        #   sp = cls.allocate
        #   # sp.introduce player_store[0] unless player_store.empty?
        #   # unless player_store.empty?
        #   #   sp.players.push player_store[0]
        #   #   player_store[0].playbooks.push sp.playbook unless player_store[0].playbooks.include?(sp.playbook)
        #   # end
        #   # @todo Assuming one player
        #   if plot.players.first
        #     sp.players.push plot.players.first
        #     plot.players.first.playbooks.push sp.playbook unless plot.players.first.playbooks.include?(sp.playbook)
        #     # @todo Assuming default scene
        #     plot.players.first.cue plot.default_scene
        #   end
        #   rebuild_subplot sp, s
        #   sp.send(:run_scripts)
        #   plot.subplots.push sp
        # end
      end

      private

      # def instance_variable_hash obj
      #   result = {}
      #   obj.instance_variables.each do |k|
      #     result[k] = obj.instance_variable_get(k).to_serial
      #   end
      #   result
      # end

      def namespace_to_constant string
        space = Object
        string.split('::').each do |part|
          space = space.const_get(part)
        end
        space
      end

      def hash_blacklist
        [:@parent, :@children, :@last_action, :@scene, :@playbook, :@performance_stack, :@buffer_stack, :@messages, :@state]
      end

      def can_serialize? v
        return true if is_simple_type?(v) or v.kind_of?(Gamefic::Entity) or is_scene_class?(v)
        if v.kind_of?(Array)
          v.each do |e|
            result = can_serialize?(e)
            return false if result == false
          end
          true
        elsif v.kind_of?(Hash)
          v.each_pair do |k, v|
            result = can_serialize?(k)
            return false if result == false
            result = can_serialize?(v)
            return false if result == false
          end
          true
        else
          false
        end
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

      def is_simple_type?(v)
        return true if v.kind_of?(String) or v.kind_of?(Numeric) or v.kind_of?(Symbol) or v == true or v == false or v.nil?
        false
      end

      def serialize v
        if v.kind_of?(Array)
          result = []
          v.each do |e|
            result.push serialize(e)
          end
          result
        elsif v.kind_of?(Hash)
          result = {}
          v.each_pair do |k, v|
            result[serialize(k)] = serialize(v)
          end
          result
        elsif v.is_a?(Symbol)
          "#<SYM:#{v}>"
        elsif is_scene_class?(v)
          i = plot.scene_classes.index(v)
          "#<SIN_#{i}>"
        elsif v.kind_of?(Gamefic::Entity)
          i = entity_store.index(v)
          if i.nil?
            i = player_store.index(v)
            if i.nil?
              raise "#{v} not found in plot"
              nil
            else
              "#<PIN_#{i}>"
            end
          else
            "#<EIN_#{i}>"
          end
        else
          v
        end
      end

      def unserialize v
        if v.kind_of?(Array)
          result = []
          v.each do |e|
            result.push unserialize(e)
          end
          result
        elsif v.kind_of?(Hash)
          result = {}
          v.each_pair do |k, v|
            result[unserialize(k)] = unserialize(v)
          end
          result
        elsif v.kind_of?(String)
          if m = v.match(/#<SIN_([0-9]+)>/)
            plot.scene_classes[m[1].to_i]
          elsif m = v.match(/#<EIN_([0-9]+)>/)
            entity_store[m[1].to_i]
          elsif m = v.match(/#<PIN_([0-9]+)>/)
            player_store[m[1].to_i]
          elsif m = v.match(/#<SYM:(.*?)>/)
            m[1].to_sym
          else
            v
          end
        else
          v
        end
      end

      def rebuild1 e, h
        h.each_pair do |k, v|
          if k.to_s.start_with?('@')
            e.instance_variable_set(k, unserialize(v))
          end
        end
      end

      def rebuild2 e, h
        h.each_pair do |k, v|
          if k.to_s != 'class' and !k.to_s.start_with?('@')
            e.send("#{k}=", unserialize(v))
          end
        end
      end

      # def hash_subplot s
      #   result = { entities: [], instance_variables: {}, theater_instance_variables: {} }
      #   s.instance_variables.each { |i|
      #     v = s.instance_variable_get(i)
      #     result[:instance_variables][i] = serialize(v) if can_serialize?(v)
      #   }
      #   s.theater.instance_variables.each { |i|
      #     v = s.theater.instance_variable_get(i)
      #     result[:theater_instance_variables][i] = serialize(v) if can_serialize?(v)
      #   }
      #   s.entities.each { |s|
      #     result[:entities].push serialize(s)
      #   }
      #   result[:class] = s.class.to_s
      #   result
      # end

      def serialize_subplot s
        {
          'entities' => s.entities.map(&:to_serial),
          'instance_variables' => s.serialize_instance_variables,
          'theater_instance_variables' => s.theater.serialize_instance_variables
        }
      end

      def rebuild_subplot s, h
        s.entities.each { |e|
          s.destroy e
        }
        h[:entities].each { |e|
          s.entities.push unserialize(e)
        }
        h[:instance_variables].each_pair { |k, v|
          s.instance_variable_set(k, unserialize(v))
        }
        h[:theater_instance_variables].each_pair { |k, v|
          s.theater.instance_variable_set(k, unserialize(v))
        }
      end

      def entity_store
        @entity_store ||= []
      end

      def player_store
        @player_store ||= []
      end

      def hash_entity e
        h = {}
        e.instance_variables.each { |i|
          v = e.instance_variable_get(i)
          h[i] = serialize(v) unless hash_blacklist.include?(i) or !can_serialize?(v)
        }
        h[:class] = e.class.to_s
        h[:parent] = serialize(e.parent)
        h
      end
    end
  end
end
