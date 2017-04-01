require 'json'

module Gamefic
  module Plot::Snapshot
  
    # Take a snapshot of the plot's current state.
    # The snapshot is a hash with two keys: entities and subplots.
    #
    # @return [Hash]
    def save
      store = get_entity_hash
      if @initial_state.nil?
        @initial_state = store
        store = []
        @initial_state.length.times do
          store.push {}
        end
      else
        store = reduce(store)
      end
      return {
        entities: store,
        subplots: save_subplots,
        metadata: metadata
      }
    end
    
    # Restore the plot to the state of the provided snapshot.
    #
    # @param [Hash]
    def restore snapshot
      restore_initial_state
      internal_restore snapshot[:entities]
      restore_subplots snapshot[:subplots]
    end
    
    private
    
    # Restore the plot to the state of its first snapshot.
    #
    def restore_initial_state
        p_entities[@initial_state.length..-1].each { |e|
          e.parent = nil
        }
        p_entities.slice! @initial_state.length..-1
        internal_restore @initial_state
    end
    
    def get_entity_hash
      store = []
      entities.each { |e|
        hash = {}
        e.instance_variables.each { |k|
          next if k == :@children
          v = e.instance_variable_get(k)
          hash[k] = v
        }
        hash[:class] = e.class.to_s
        store.push serialize_object(hash)
      }
      store
    end
    
    def internal_restore snapshot
      index = 0
      snapshot.each { |hash|
        if entities[index].nil?
          cls = Kernel.const_get(hash[:class])
          p_entities[index] = make cls
        end 
        internal_restore_hash hash, index
        index += 1
      }
      nil
    end

    def internal_restore_hash hash, index
      hash.each { |k, v|
        if k == :scene
          entities[index].cue v.to_sym
        elsif (k != :class)
          entities[index].instance_variable_set(k, unserialize(v))
        end
      }
      nil
    end

    def reduce entities
      reduced = []
      index = 0
      entities.each { |e|
        r = {}
        e.each_pair { |k, v|
          if index >= @initial_state.length or @initial_state[index][k] != v
            r[k] = v
          end
        }
        reduced.push r
        index += 1
      }
      reduced
    end

    def can_serialize? obj
      return true if (obj == true or obj == false or obj.nil?)
      allowed = [String, Fixnum, Float, Numeric, Entity, Direction, Hash, Array, Symbol]
      allowed.each { |a|
        return true if obj.kind_of?(a)
      }
      false
    end

    def serialize_object obj
      return nil if obj.nil?
      return false if obj == false
      if obj.kind_of?(Hash)
        return serialize_hash obj
      elsif obj.kind_of?(Array)
        return serialize_array obj
      else
        if obj.kind_of?(Entity)
          return "#<EIN_#{p_entities.index(obj)}>"
        elsif obj.kind_of?(Direction)
          return "#<DIR_#{obj.name}>"
        end
      end
      return obj
    end

    def serialize_hash obj
      hash = {}
      obj.each_pair { |k, v|
        if can_serialize?(k) and can_serialize?(v)
          hash[serialize_object(k)] = serialize_object(v)
        end
      }
      return hash
    end

    def serialize_array obj
      arr = []
      obj.each_index { |i|
        if can_serialize?(obj[i])
          arr[i] = serialize_object(obj[i])
        else
          raise "Bad array in snapshot"
        end
      }
      return arr
    end

    def unserialize obj
      if obj.kind_of?(Hash)
        unserialize_hash obj
      elsif obj.kind_of?(Array)
        unserialize_array obj
      elsif obj.to_s.match(/^#<EIN_[0-9]+>$/)
        i = obj[6..-2].to_i
        p_entities[i]
      elsif obj.to_s.match(/^#<DIR_[a-z]+>$/)
        Direction.find(obj[6..-2])
      else
        obj
      end
    end

    def unserialize_hash obj
      hash = {}
      obj.each_pair { |k, v|
        hash[unserialize(k)] = unserialize(v)
      }
      hash
    end

    def unserialize_array obj
      arr = []
      obj.each_index { |i|
        arr[i] = unserialize(obj[i])
      }
      arr
    end

    def save_subplots
      # TODO: Subplot snapshots are temporarily disabled.
      return []
      arr = []
      subplots.each { |s|
        hash = {}
        hash[:class] = s.class.to_s
        s.instance_variables.each { |k|
          v = s.instance_variable_get(k)
          if can_serialize?(v)
            hash[k] = serialize_object(v)
          end
        }
        arr.push hash
      }
      arr
    end
    
    def restore_subplots arr
      # TODO: Subplot snapshots are temporarily disabled.
      return
      players.each { |p|
        p.send(:p_subplots).clear
      }
      p_subplots.clear
      arr.each { |hash|
        cls = Kernel.const_get(hash[:class])
        subplot = cls.new self
        hash.each { |k, v|
          if k != :class
            subplot.instance_variable_set(k, unserialize(v))
          end
        }
        subplot.players.each { |p|
          p.send(:p_subplots).push subplot
        }
        subplot.entities.each { |e|
          e.extend Subplot::Element
          e.instance_variable_set(:@subplot, subplot)
        }
        p_subplots.push subplot
      }
    end
  end
end
