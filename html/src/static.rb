require 'gamefic'
# HACK Explicit requires to fix Opal's failure to resolve autoloads
require 'gamefic/query/expression'
require 'gamefic/query/matches'
require 'gamefic/grammar/verb_set'

class WebPlot < Gamefic::Plot
  def stage *args, &block
    if block.nil?
      instance_eval(*args)
    else
      instance_exec(*args, &block)
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
    @@static_player ||= WebUser.new(Gamefic::GameficOpal.static_plot)
  end
end

def method_missing(symbol, *args, &block)
  if GameficOpal.static_plot.respond_to?(symbol)
    GameficOpal.static_plot.send(symbol, *args, &block)
  else
    raise NameError.new("Unrecognized method #{symbol}")
  end
end

require 'main'
