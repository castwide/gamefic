class OptionSet
  attr_accessor :options
  attr_reader :default
  def initialize *args
    @options = args
    if @options.length == 0
      raise "No options defined"
    end
    if @options.length == 1
      raise "Option sets require at least 2 options"
    end
    @default = @options[0]
  end
  def default=(val)
    if @options.include?(val) == false
      raise "Option #{val} not available"
    end
    @default = val
  end
end

module OptionMap
  def option_map
    @option_map ||= Hash.new
  end
  def options cls, *args
    os = OptionSet.new(*args)
    option_map[cls] ||= {}
    os.options.each { |o|
      if option_map[cls][o] != nil
        raise "Option #{o} already exists"
      end
      option_map[cls][o] = os
    }
    os
  end
  def get_default_for(cls, opt)
    os = get_option_set_for(cls, opt)
    if os == nil
      raise "Option does not exist"
    end
    return os.default
  end
  def set_default_for(cls, opt)
    os = get_option_set_for(cls, opt)
    raise "No #{opt} for #{cls}" if os.nil?
    os.default = opt
  end
  def get_all_option_sets_for(cls)
    all = []
    option_map.each_value { |s|
      s.each_key { |o|
        set = get_option_set_for(cls, o, false)
        if set != nil
          all.push set
        end
      }
    }
    all.uniq
  end
  def get_option_set_for(cls, opt, create_if_inherited = true)
    if option_map[cls] and option_map[cls][opt]
      return option_map[cls][opt]
    else
      from = cls.superclass
      while from != nil
        if option_map[from] and option_map[from][opt]
          os = option_map[from][opt]
          if os != nil and create_if_inherited == true
            os = os.clone
            option_map[cls] ||= {}
            os.options.each { |o|
              option_map[cls][o] = os
            }
          end
          if os != nil
            return os
          end
        end
        from = from.superclass
      end
    end
    return nil
  end
end

module OptionSettings
  attr_reader :option_mapper
  def option_mapper
    raise "Object does not have an option mapper" if @option_mapper.nil?
    @option_mapper
  end
  def option_array
    @option_array ||= []
  end
  def option_select(opt)
    if option_array.include?(opt) == false
      set = option_mapper.get_option_set_for(self.class, opt)
      if set == nil
        raise "Invalid option #{opt}"
      end
      (set.options - [opt]).each { |o|
        option_array.delete o
      }
      option_array.push opt
    end
  end
  def option_unselect(opt)
    set = option_mapper.get_option_set_for(self.class, opt)
    if set == nil
      raise "Invalid option #{opt}"
    end
    option_array.delete opt
  end
  def option_selected?(opt)
    set = option_mapper.get_option_set_for(self.class, opt)
    if set.nil?
      if opt.to_s[0..3] == 'not_'
        return true
      else
        return false
      end
    end
    return true if option_array.include?(opt)
    other = set.options & option_array
    if other.length == 0 and set.default == opt
      return true
    end
    return false
  end
  def option_from_set(os)
    os.options.each { |o|
      if self.is?(o)
        return o
      end
    }
    nil
  end
  def is(*opts)
    opts.each { |opt|
      option_select opt
    }
  end
  def is?(opt)
    option_selected?(opt)
  end
end
