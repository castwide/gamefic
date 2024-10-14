# frozen_string_literal: true

require 'set'

module Gamefic
  # A class module that enables scripting.
  #
  # Including `Gamefic::Scripting` also extend `Gamefic::Scriptable`.
  #
  # Narratives extend Scriptable to enable definition of scripts and seeds.
  # Modules can also be extended with Scriptable to make them includable to
  # other Scriptables.
  #
  # @example Include a scriptable module in a plot
  #   module MyScript
  #     extend Gamefic::Scriptable
  #
  #     respond :myscript do |actor|
  #       actor.tell "This command was added by MyScript"
  #     end
  #   end
  #
  #   class MyPlot < Gamefic::Plot
  #     include MyScript
  #   end
  #
  module Scriptable
    autoload :Entities,    'gamefic/scriptable/entities'
    autoload :Hooks,       'gamefic/scriptable/hooks'
    autoload :Queries,     'gamefic/scriptable/queries'
    autoload :Responses,   'gamefic/scriptable/responses'
    autoload :Scenes,      'gamefic/scriptable/scenes'
    autoload :Seeds,       'gamefic/scriptable/seeds'
    autoload :Syntaxes,    'gamefic/scriptable/syntaxes'

    include Entities
    include Hooks
    include Queries
    include Responses
    include Scenes
    include Seeds

    # Add a block of code to be executed during initialization.
    #
    # These blocks are primarily used to define actions, scenes, and hooks in
    # the narrative's rulebook. Entities and game data should be initialized
    # with `seed`.
    #
    # @example
    #   class MyPlot < Gamefic::Plot
    #     script do
    #       introduction do |actor|
    #         actor.tell 'Hello, world!'
    #       end
    #
    #       respond :wait do |actor|
    #         actor.tell 'Time passes.'
    #       end
    #     end
    #   end
    #
    def script &block
      Gamefic.logger.warn "The `script` method is deprecated. Use class-level script methods instead."
      instance_exec(&block)
    end

    def included_scripts
      included_modules.that_are(Scriptable).uniq
    end

    def bind *methods
      bound_methods.merge methods
    end

    def bound_methods
      @bound_methods ||= Set.new
    end
  end
end
