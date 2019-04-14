module Gamefic
  # An entity that is capable of performing actions and participating in
  # scenes.
  #
  class Actor < Gamefic::Entity
    include Gamefic::Active
  end
end
