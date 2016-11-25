require 'json'

module Gamefic
  module Plot::Snapshot
  
    # Take a snapshot of the plot's current state.
    #
    # @return [Hash]
    def save
      store = []
      index = 0
      entities.each { |e|
        hash = {}
        e.serialized_attributes.each {|m|
          con = m.to_s
          if con.end_with?("?")
            con = con[0..-2]
          end
          if e.respond_to?(m) == true
            begin
              val = e.send(m)
              if val == false
                hash[con] = false
              elsif val
                hash[con] = serialize_obj(val)
              else
                hash[con] = nil
              end
            rescue Exception => error
              hash[con] = nil
            end
          end
        }
        hash[:class] = e.class.to_s
        hash[:session] = {}
        e.session.each_pair { |k, v|
          hash[:session][k] = serialize_obj(v)
        }
        store.push hash
        index += 1
      }
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
        subplots: save_subplots
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
        @entities[@initial_state.length..-1].each { |e|
          e.parent = nil
        }
        @entities.slice! @initial_state.length..-1
        internal_restore @initial_state
    end
    
    def internal_restore snapshot
      index = 0
      snapshot.each { |hash|
        if entities[index].nil?
          cls = Kernel.const_get(hash[:class])
          @entities[index] = make cls
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
        elsif (k != :session and k != :class)
          entities[index].send("#{k}=", unserialize(v))
        end
        unless hash[:session].nil?
          hash[:session].each_pair { |k, v|
            entities[index].session[k.to_sym] = unserialize(v)
          }
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
    def serialize_obj obj
      return nil if obj.nil?
      return false if obj == false
      if obj.kind_of?(Hash)
        return serialize_hash obj
      elsif obj.kind_of?(Array)
        return serialize_array obj
      else
        if obj.kind_of?(Entity)
          return "#<EIN_#{@entities.index(obj)}>"
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
          hash[serialize_obj(k)] = serialize_obj(v)
        end
      }
      return hash
    end
    def serialize_array obj
      arr = []
      obj.each_index { |i|
        if can_serialize?(obj[i])
          arr[i] = serialize_obj(obj[i])
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
        @entities[i]
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
      arr = []
      subplots.each { |s|
        hash = {}
        hash[:class] = s.class.to_s
        s.instance_variables.each { |k|
          v = s.instance_variable_get(k)
          if can_serialize?(v)
            hash[k] = serialize_obj(v)
          end
        }
        arr.push hash
      }
      arr
    end
    def restore_subplots arr
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
        p_subplots.push subplot
      }
    end
  end
end
