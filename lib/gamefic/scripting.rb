# frozen_string_literal: true

module Gamefic
  # An instance module that enables scripting.
  #
  # Including `Gamefic::Scripting` also extends `Gamefic::Scriptable`.
  #
  module Scripting
    require 'gamefic/scripting/proxies'
    require 'gamefic/scripting/entities'
    require 'gamefic/scripting/hooks'
    require 'gamefic/scripting/responses'
    require 'gamefic/scripting/syntaxes'
    require 'gamefic/scripting/seeds'
    require 'gamefic/scripting/scenes'

    extend Scriptable
    include Scriptable::Queries
    include Entities
    include Hooks
    include Responses
    include Seeds
    include Scenes
    include Syntaxes

    # @return [Array<Module<Scriptable>>]
    def included_scripts
      self.class.included_scripts
    end

    # @param symbol [Symbol]
    # @return [Array<Binding>]
    def find_and_bind(symbol)
      included_scripts.flat_map { |script| script.send(symbol) }
                      .map { |blk| Binding.new(self, blk) }
    end

    def self.included other
      super
      other.extend Scriptable
    end
  end
end
