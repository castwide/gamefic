module Gamefic

  class Entity
    def key
      if @key == nil
        stack = Array.new
        stack.push longname
        p = @parent
        while p != nil
          stack.push p.longname
          p = p.parent
        end
        @key = stack.join("|")
      end
      @key
    end
  end

  class Key
    def initialize(key_value)
      @value = key_value
    end
    def value
      @value
    end
  end
  
  class WebEngine < Engine
    attr_reader :user
		def initialize(plot)
      super
      @restored = false
      @entity_keys = Hash.new
      @user = WebUser.new @plot
      plot.entities.each { |e|
        @entity_keys[e.key] = e
      }
      @entity_keys['player'] = @user.character
    end
    def load(filename)
      #x = File.read(filename)
      x = File.open(filename, "r")
      ser = x.read
      x.close
      data = Marshal.restore(ser)
      data.each { |k, h|
        if k == 'player'
          entity = @entity_keys['player']
        else
          entity = @entity_keys[k]
        end
        h.each { |s, v|
          if s == :session
            entity.instance_variable_set(:@session, v)
          else
            writer = "#{s.to_s[1..-1]}="
            if entity.respond_to?(writer)
              if v.kind_of?(Key)
                if v.value == 'player'
                  entity.send(writer, @entity_keys['player'])
                else
                  entity.send(writer, @entity_keys[v.value])
                end
              elsif v.kind_of?(CharacterState)
                v.instance_variable_set(:@character, entity)
                entity.instance_variable_set(s, v)
              elsif v.kind_of?(Array)
                entity.send(writer, decode_array(v))
              else
                entity.send(writer, v)
              end
            end
          end
        }
      }
      @restored = true
    end
		def run
      if @restored == false
        @plot.introduce @user.character
      else
        @user.stream.select
        @user.state.update
        @plot.update
      end
      @user.character.tell @user.character.state.prompt
		end
    def save(filename)
      data = Hash.new
      @plot.entities.each { |e|
        data[e.key] = entity_hash(e)
      }
      data['player'] = entity_hash(@user.character)
      f = File.new(filename, "w")
      f.write Marshal.dump data
      f.close
    end
    def entity_hash(e)
      hash = Hash.new
      e.instance_variables.each { |v|
        writer = "#{v.to_s[1..-1]}="
        if e.respond_to?(writer)
          value = e.instance_variable_get(v)
          if value.kind_of?(String) or value.kind_of?(Numeric) or value.kind_of?(TrueClass) or value.kind_of?(FalseClass) or value.kind_of?(Entity) or value.kind_of?(Character) or value.kind_of?(CharacterState) or value == nil or value.kind_of?(Array)
            if value.kind_of?(Entity)
              if value == @user.character
                hash[v] = Key.new('player')
              else
                hash[v] = Key.new(value.key)
              end
            elsif value.kind_of?(CharacterState)
              value.instance_variable_set(:@character, nil)
              hash[v] = value
            elsif value.kind_of?(Array)
              hash[v] = encode_array(value)
            else
              hash[v] = value
            end
          end
        end
      }
      hash[:session] = e.session
      hash
    end
    def encode_array(array)
      result = Array.new
      array.each { |item|
        if item.kind_of?(Entity)
          result.push Key.new(item.key)
        else
          result.push item
        end
      }
      result
    end
    def decode_array(array)
      result = Array.new
      array.each { |item|
        if item.kind_of?(Key)
          result.push @entity_keys[item.value]
        else
          result.push item
        end
      }
      result    
    end
  end
  
end
