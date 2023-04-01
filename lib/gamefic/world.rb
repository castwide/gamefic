module Gamefic
  # A collection of classes and modules related to generating a world model.
  #
  module World
    autoload :Books,     'gamefic/world/books'
    autoload :Entities,  'gamefic/world/entities'
    autoload :Commands,  'gamefic/world/commands'
    autoload :Scenes,    'gamefic/world/scenes'
    autoload :Players,   'gamefic/world/players'

    include Books
    include Entities
    include Commands
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
      static = ([self] + entities).freeze
      define_singleton_method :static do
        static
      end
    end
  end
end
