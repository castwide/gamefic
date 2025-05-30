# frozen_string_literal: true

require 'set'

module Gamefic
  # A class module that enables scripting.
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
    require 'gamefic/scriptable/hooks'
    require 'gamefic/scriptable/queries'
    require 'gamefic/scriptable/syntaxes'
    require 'gamefic/scriptable/responses'
    require 'gamefic/scriptable/scenes'
    require 'gamefic/scriptable/seeds'

    include Hooks
    include Queries
    include Responses
    include Scenes
    include Seeds
    include Syntaxes

    def included_scripts
      ancestors.that_are(Scriptable).uniq
    end
  end
end
