module Gamefic
  def self.static_plot
    @@static_plot ||= Plot.new
  end
  def self.static_player
    @@static_player ||= User.new(static_plot)
  end
end
