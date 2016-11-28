# HACK Explicit requires to fix Opal's failure to resolve autoloads
require 'gamefic/query/expression'
require 'gamefic/query/matches'
require 'gamefic/grammar/verb_set'
require 'gamefic/scene/multiple_choice/input'

# HACK Opal doesn't recognize classes and modules declared from scripts
def Object.const_missing sym
  Gamefic.const_get sym
end

module GameficOpal
  def self.static_plot
    @@static_plot ||= WebPlot.new(Gamefic::Source::Text.new)
  end
  def self.static_player
    @@static_player ||= WebUser.new(GameficOpal.static_plot)
  end

  class WebPlot < Gamefic::Plot
    def script path
      # Stub
    end
  end

  class WebUser < Gamefic::User
    def save filename, data
      data[:metadata] = character.plot.metadata
      `Gamefic.save(filename, data);`
    end
    def restore filename
      data = `Gamefic.restore(filename);`
      return data
    end
    def test_queue
      character[:test_queue] || []
    end
  end
end

GameficOpal.static_plot.script 'main'
