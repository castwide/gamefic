# frozen_string_literal: true

require_relative './modular_test_script'

class ModularTestPlot < Gamefic::Plot
  include ModularTestScript

  introduction do |actor|
    actor.parent = place
  end
end
