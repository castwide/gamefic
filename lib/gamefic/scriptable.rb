# frozen_string_literal: true

module Gamefic
  # A collection of methods that can be used in Gamefic scripts.
  #
  # Scriptable modules are designed to integrate narratives with theaters.
  # Narratives assign a delegator module that includes all the scriptables
  # required by the narrative's scripts. Theaters forward scriptable method
  # calls to the narrative.
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
