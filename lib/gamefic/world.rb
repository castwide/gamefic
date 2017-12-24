module Gamefic
  module World
    autoload :Entities,  'gamefic/world/entities'
    autoload :Commands,  'gamefic/world/commands'
    autoload :Callbacks, 'gamefic/world/callbacks'
    autoload :Scenes,    'gamefic/world/scenes'
    autoload :Players,   'gamefic/world/players'
    autoload :Theater,   'gamefic/world/theater'
    autoload :Playbook,  'gamefic/world/playbook'

    include Entities
    include Commands
    include Callbacks
    include Scenes
    include Players
    include Theater
  end
end
