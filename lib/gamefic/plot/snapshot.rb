require 'json'

module Gamefic
  module Plot::Snapshot
    # @return [Hash]
    def save
      initial_state
      internal_save
    end
    
    def restore snapshot
      entities[initial_state.length..-1].each do |e|
        destroy e
      end
      entities.slice! initial_state.length..-1
      i = 0
      snapshot[:entities].each { |h|
        if entities[i].nil?
          e = stage "make #{h[:class]}"
          STDERR.puts "Made a #{e.class}"
          entities.push e
        end
        rebuild1 entities[i], h
        i += 1
      }
      i = 0
      snapshot[:entities].each { |h|
        rebuild2 entities[i], h
        i += 1
      }
    end

    def initial_state
      if @initial_state.nil?
        @initial_state = internal_save
      end
      @initial_state
    end

    private

    def internal_save
      h = { entities: [] }
      entities.each { |e|
        h[:entities].push hash_entity(e)
      }
      h
    end

    def hash_blacklist
      [:@parent, :@children, :@last_action, :@scene, :@next_scene, :@playbook, :@performance_stack]
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
      end
    end

    def is_scene_class?(v)
      if v.kind_of?(Class)
        s = v
        until s.nil?
          return true if s == Gamefic::Scene
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
        i = scene_classes.index(v)
        "#<SIN_#{i}>"
      elsif v.kind_of?(Gamefic::Entity)
        i = entities.index(v)
        "#<EIN_#{i}>"
      else
        v
      end
    end

    def unserialize v
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
      elsif v.kind_of?(String)
        if m = v.match(/#<SIN_([0-9]+)>/)
          scene_classes[m[1].to_i]
        elsif m = v.match(/#<EIN_([0-9]+)>/)
          entities[m[1].to_i]
        else
          v
        end
      else
        v
      end
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

    def rebuild1 e, h
      STDERR.puts "Rebuilding 1: #{e}"
      h.each_pair do |k, v|
        if k.to_s.start_with?('@')
          STDERR.puts "Setting #{k}"
          e.instance_variable_set(k, unserialize(v))
        end
      end
    end

    def rebuild2 e, h
      STDERR.puts "Rebuilding 2: #{e}"
      h.each_pair do |k, v|
        if k.to_s != 'class' and !k.to_s.start_with?('@')
          e.send("#{k}=", unserialize(v))
        end
      end
    end
  end
end
