module Gamefic
  # A collection of methods that can be used in Gamefic scripts.
  #
  # Scriptable modules are designed to be integrate narratives with theaters.
  # Narratives include the modules Theaters forward the messages.
  #
  module Scriptable
    autoload :Actions,  'gamefic/scriptable/actions'
    autoload :Entities, 'gamefic/scriptable/entities'
    autoload :Queries,  'gamefic/scriptable/queries'
    autoload :Plots,    'gamefic/scriptable/plots'
    autoload :Scenes,   'gamefic/scriptable/scenes'
    autoload :Subplots, 'gamefic/scriptable/subplots'
  end
end
