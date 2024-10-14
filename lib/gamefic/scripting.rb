# frozen_string_literal: true

module Gamefic
  # An instance module that enables scripting.
  #
  # Including `Gamefic::Scripting` also extend `Gamefic::Scriptable`.
  #
  module Scripting
    require 'gamefic/scripting/proxies'
    require 'gamefic/scripting/entities'
    require 'gamefic/scripting/hooks'
    require 'gamefic/scripting/responses'
    require 'gamefic/scripting/seeds'
    require 'gamefic/scripting/scenes'

    include Scriptable::Queries
    include Entities
    include Hooks
    include Responses
    include Seeds
    include Scenes

    def bound_methods
      self.class.bound_methods.to_a
    end

    def bound? method
      self.class.bound_methods.include?(method)
    end

    def included_scripts
      self.class
          .included_modules
          .that_are(Scriptable)
    end

    def find_and_bind(symbol)
      included_scripts.flat_map { |script| script.send(symbol) }
                      .concat(self.class.send(symbol))
                      .map { |blk| Binding.new(self, blk) }
    end

    def self.included other
      super
      other.extend Scriptable
    end
  end
end
