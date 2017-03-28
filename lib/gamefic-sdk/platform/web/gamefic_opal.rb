# HACK Explicit requires to fix Opal's failure to resolve autoloads
require 'gamefic/query/expression'
require 'gamefic/query/matches'
require 'gamefic/grammar/verb_set'
require 'gamefic/plot/playbook'

# HACK Opal doesn't recognize classes and modules declared from scripts
def Object.const_missing sym
  Gamefic.const_get sym
end

module GameficOpal
  def self.static_plot
    @@static_plot ||= WebPlot.new(Gamefic::Source::Text.new)
  end
  def self.static_character
    if @@static_character.nil?
      @@static_character = static_plot.make Gamefic::Character, name: 'player', synonyms: 'me you myself yourself self'
      @@static_character.connect static_user
    end
    @@static_character
  end
  def self.static_user
    @@static_user ||= WebUser.new
  end
  class WebPlot < Gamefic::Plot
    def script path
      # Stub
    end
    def public_method sym
      method(sym)
    end
  end

  class WebUser < Gamefic::User::Base
    def save filename, data
      data[:metadata] = GameficOpal.static_plot.metadata
      `Gamefic.save(filename, data);`
    end
    def restore filename
      data = `Gamefic.restore(filename);`
      return data
    end
    def test_queue
      GameficOpal.static_character[:test_queue] || []
    end
  end
end
