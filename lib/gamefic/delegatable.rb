# frozen_string_literal: true

module Gamefic
  # A collection of modules that provide delegated methods for narratives.
  # See `Gamefic::Narrative`, `Gamefic::Plot`, and `Gamefic::Subplot` for
  # examples of delegation.
  #
  module Delegatable
    autoload :Actions,  'gamefic/delegatable/actions'
    autoload :Entities, 'gamefic/delegatable/entities'
    autoload :Queries,  'gamefic/delegatable/queries'
    autoload :Plots,    'gamefic/delegatable/plots'
    autoload :Scenes,   'gamefic/delegatable/scenes'
    autoload :Sessions, 'gamefic/delegatable/sessions'
    autoload :Subplots, 'gamefic/delegatable/subplots'
  end
end
