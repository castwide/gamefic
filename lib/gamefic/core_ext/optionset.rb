class OptionSet
  @@option_map = Hash.new # map class to optionset
  attr_accessor :options
  attr_reader :default
  def initialize cls, *args
    @options = args
    if @options.length == 0
      raise "No options defined"
    end
    if @options.length == 1
      @options.push "not_#{args[0]}".to_sym
    end
    @@option_map[cls] ||= {}
    @options.each { |o|
      if @@option_map[cls][o] != nil
        raise "Option #{o} already exists"
      end
      @@option_map[cls][o] = self
    }
  end
  def default=(val)
    if @options.include?(val) == false
      raise "Option #{val} not available"
    end
    @default = val
  end
  def self.get_default_for(cls, opt)
    os = OptionSet.get_option_set_for(cls, opt)
    if os == nil
      raise "Option does not exist"
    end
    return os.default
  end
  def self.set_default_for(cls, opt)
    os = OptionSet.get_option_set_for(cls, opt)
    os.default = opt
  end
  def self.get_all_option_sets_for(cls)
    puts "Checking sets"
    all = []
    @@option_map.each_value { |s|
      s.each_key { |o|
        puts "Option: #{o}"
        set = OptionSet.get_option_set_for(cls, o, false)
        if set != nil
          puts "Got a set"
          all.push set
        end
      }
    }
    puts all.length
    all.uniq
  end
  def self.get_option_set_for(cls, opt, create_if_inherited = true)
    if @@option_map[cls] and @@option_map[cls][opt]
      return @@option_map[cls][opt]
    elsif cls.superclass
      os = get_option_set_for(cls.superclass, opt)
      if os != nil and create_if_inherited == true
        os = OptionSet.new(cls, *os.options)
      end
      return os
    end
    return nil
  end
end

module OptionSettings
  def option_array
    @option_array ||= []
  end
  def option_select(opt)
    if option_array.include?(opt) == false
      set = OptionSet.get_option_set_for(self.class, opt)
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
    set = OptionSet.get_option_set_for(self.class, opt)
    if set == nil
      raise "Invalid option #{opt}"
    end
    option_array.delete opt
  end
  def option_selected?(opt)
    set = OptionSet.get_option_set_for(self.class, opt)
    if set == nil
      raise "Undefined option #{opt}"
    end
    return true if option_array.include?(opt)
    other = set.options & option_array
    if other.length == 0 and set.default == opt
      return true
    end
    return false
  end
  def is(opt)
    option_select opt
  end
  def is?(opt)
    option_selected?(opt)
  end
end

class Object
  include OptionSettings
end
