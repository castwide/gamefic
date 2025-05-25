# frozen_string_literal: true

class ModularTestPlot < Gamefic::Plot
  include ModularTestScript

  introduction do |actor|
    actor.parent = place
  end
end
