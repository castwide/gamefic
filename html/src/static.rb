module Gamefic
  def self.static_plot
    @@static_plot ||= Plot.new
  end
  class WebUser < User
    def save
      `Gamefic.Engine.save();`
    end
    def restore
      `Gamefic.Engine.restore();`
    end
  end
  def self.static_player
    @@static_player ||= WebUser.new(static_plot)
  end
end
