module Gamefic
  # A collection of methods that can be used in Gamefic scripts.
  #
  # This module is designed to be shared between the Plot and the Theater.
  # Plots include this module directly. Theaters forward the messages.
  #
  module Scriptable
    autoload :Actions, 'gamefic/scriptable/actions'
    autoload :Entities, 'gamefic/scriptable/entities'
    autoload :Queries, 'gamefic/scriptable/queries'
    autoload :Scenes, 'gamefic/scriptable/scenes'

    include Actions
    include Entities
    include Queries
    include Scenes
  end
end
