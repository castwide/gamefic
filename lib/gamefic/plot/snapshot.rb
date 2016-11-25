require 'json'

module Gamefic
  module Plot::Snapshot
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
      store
    end
    def restore snapshot
      restore_initial_state
      internal_restore snapshot
    end
    
    private
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
          if with_restore
            cls = Kernel.const_get(hash[:class])
            entities[index] = make cls
          else
            break
          end
        end 
        hash.each_pair { |k, v|
          if k == :scene
            entities[index].cue v.to_sym
          else
            entities[index].send("#{k}=", unserialize(v)) if k != :session and k != :class
          end
        }
        unless hash[:session].nil?
          hash[:session].each_pair { |k, v|
            entities[index].session[k.to_sym] = unserialize(v)
          }
        end
        index += 1
      }
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
      else
        if obj.to_s.match(/^#<EIN_[0-9]+>$/)
          i = obj[6..-2].to_i
          @entities[i]
        elsif obj.to_s.match(/^#<DIR_[a-z]+>$/)
          Direction.find(obj[6..-2])
        else
          obj
        end
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
  end
end
