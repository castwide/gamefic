module Gamefic
  module World
    autoload :Playbook,  'gamefic/world/playbook'
    autoload :Entities,  'gamefic/world/entities'
    autoload :Commands,  'gamefic/world/commands'
    autoload :Callbacks, 'gamefic/world/callbacks'
    autoload :Scenes,    'gamefic/world/scenes'
    autoload :Players,   'gamefic/world/players'

    include Entities
    include Commands
    include Callbacks
    include Scenes
    include Players
  end
end
