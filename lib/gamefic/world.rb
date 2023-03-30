module Gamefic
  # A collection of classes and modules related to generating a world model.
  #
  module World
    autoload :Playbook,  'gamefic/world/playbook'
    autoload :Scenebook,  'gamefic/world/scenebook'
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

    # @!method static
    #   An array of objects that were created during initialization.
    #   @return [Array<Object>]

    private

    # Plots and subplots track objects created in scripts to facilitate
    # serialization. This method creates a `static` method that provides them
    # as a frozen array.
    #
    def define_static
      static = ([self] + scene_classes + entities).freeze
      define_singleton_method :static do
        static
      end
    end
  end
end
