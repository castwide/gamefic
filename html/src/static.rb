include Gamefic

class WebPlot < Gamefic::Plot
  def stage *args, &block
    if block.nil?
      instance_eval(*args)
    else
      instance_exec(*args, &block)
    end
  end
end

class Module
  # HACK Fix name resolution issues in Opal
  alias_method :orig_const_missing, :const_missing
  def const_missing(sym)
    begin
      orig_const_missing sym
    rescue Exception => e
      if WebPlot.constants(false).include?(sym)
        return WebPlot.const_get(sym, false)
      elsif Gamefic.constants(false).include?(sym)
        return Gamefic.const_get(sym, false)
      end
      raise e
    end
  end
end

class WebUser < Gamefic::User
  def save filename, data
    `Gamefic.Engine.save(filename, data);`
  end
  def restore filename
    data = `Gamefic.Engine.restore(filename);`
    return data
  end
end

module GameficOpal
  def self.static_plot
    @@static_plot ||= WebPlot.new
  end
  def self.static_player
    @@static_player ||= WebUser.new(GameficOpal.static_plot)
  end
end
