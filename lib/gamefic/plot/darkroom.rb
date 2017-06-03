module Gamefic
  # Create and restore plot snapshots.
  #
  class Plot::Darkroom
    attr_reader :plot

    def initialize plot
      @plot = plot
    end

    # Create a snapshot of the plot.
    #
    # @return [Hash]
    def save
      result = { entities: [], players: [], subplots: [], instance_variables: {} }
      entity_store.clear
      player_store.clear
      entity_store.concat plot.entities
      player_store.concat plot.players
      plot.subplots.each { |s| entity_store.concat s.entities }
      entity_store.uniq!
      entity_store.each do |e|
        result[:entities].push hash_entity(e)
      end
      player_store.each do |p|
        result[:players].push hash_entity(p)
      end
      plot.theater.instance_variables.each { |i|
        v = plot.theater.instance_variable_get(i)
        result[:instance_variables][i] = serialize(v) if can_serialize?(v)
      }
      plot.subplots.each { |s|
        result[:subplots].push hash_subplot(s)
      }
      result
    end

    # Restore a snapshot.
    #
    def restore snapshot
      entity_store.clear
      player_store.clear
      plot.subplots.each { |s| s.conclude }
      plot.entities[plot.initial_state[:entities].length..-1].each { |e| plot.destroy e }
      entity_store.concat plot.entities[0..plot.initial_state[:entities].length-1]
      entity_store.uniq!
      player_store.concat plot.players
      i = 0
      snapshot[:entities].each { |h|
        if entity_store[i].nil?
          e = plot.stage do
            cls = self.const_get(h[:class])
            make cls
          end
          entity_store.push e
        end
        i += 1
      }
      snapshot[:subplots].each { |s|
        sp = plot.stage do
          cls = const_get(s[:class])
          branch cls
        end
        # @todo Assuming one player
        sp.introduce player_store[0]
        rebuild_subplot sp, s
      }
      i = 0
      snapshot[:entities].each { |h|
        rebuild1 entity_store[i], h
        i += 1
      }
      i = 0
      snapshot[:players].each { |p|
        rebuild1 player_store[i], p
        i += 1
      }
      i = 0
      snapshot[:entities].each { |h|
        rebuild2 entity_store[i], h
        i += 1
      }
      i = 0
      snapshot[:players].each { |h|
        rebuild2 player_store[i], h
        i += 1
      }
      snapshot[:instance_variables].each_pair { |k, v|
        plot.theater.instance_variable_set(k, unserialize(v))
      }
    end

    private

    def hash_blacklist
      [:@parent, :@children, :@last_action, :@scene, :@next_scene, :@playbook, :@performance_stack, :@buffer_stack, :@messages, :@state]
    end

    def can_serialize? v
      return true if v.kind_of?(String) or v.kind_of?(Numeric) or v.kind_of?(Symbol) or v.kind_of?(Gamefic::Entity) or is_scene_class?(v) or v == true or v == false or v.nil?
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

    def hash_subplot s
      result = { entities: [], instance_variables: {}, theater_instance_variables: {} }
      s.instance_variables.each { |i|
        v = s.instance_variable_get(i)
        result[:instance_variables][i] = serialize(v) if can_serialize?(v)
      }
      s.theater.instance_variables.each { |i|
        v = s.theater.instance_variable_get(i)
        result[:theater_instance_variables][i] = serialize(v) if can_serialize?(v)
      }
      s.entities.each { |s|
        result[:entities].push serialize(s)
      }
      result[:class] = s.class.to_s.split('::').last
      result
    end

    def rebuild_subplot s, h
      s.entities.each { |e|
        s.destroy e
      }
      h[:instance_variables].each_pair { |k, v|
        s.instance_variable_set(k, unserialize(v))
      }
      h[:theater_instance_variables].each_pair { |k, v|
        s.theater.instance_variable_set(k, unserialize(v))
      }
      i = 0
      h[:entities].each { |e|
        s.add_entity unserialize(e)
        i += 1
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
      h[:class] = e.class.to_s.split('::').last
      h[:parent] = serialize(e.parent)
      h
    end
  end
end
