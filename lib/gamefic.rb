# frozen_string_literal: true

require 'gamefic/version'
require 'gamefic/logging'
require 'gamefic/core_ext/array'
require 'gamefic/core_ext/string'
require 'gamefic/syntax'
require 'gamefic/response'
require 'gamefic/rulebook'
require 'gamefic/query'
require 'gamefic/scanner'
require 'gamefic/scope'
require 'gamefic/command'
require 'gamefic/action'
require 'gamefic/scene'
require 'gamefic/take'
require 'gamefic/scriptable'
require 'gamefic/delegatable'
require 'gamefic/block'
require 'gamefic/vault'
require 'gamefic/narrative'
require 'gamefic/plot'
require 'gamefic/host'
require 'gamefic/subplot'
require 'gamefic/snapshot'
require 'gamefic/node'
require 'gamefic/describable'
require 'gamefic/messenger'
require 'gamefic/entity'
require 'gamefic/dispatcher'
require 'gamefic/active'
require 'gamefic/active/cue'
require 'gamefic/actor'

module Gamefic
  # A shortcut to Gamefic::Plot.script.
  #
  # @see Gamefic::Plot.script
  #
  # @yieldself [Plot::ScriptMethods]
  def self.script &block
    Gamefic::Plot.script(&block)
  end

  # A shortcut to Gamefic::Plot.seed.
  #
  # @see Gamefic::Plot.seed
  #
  # @yieldself [Plot::ScriptMethods]
  def self.seed &block
    Gamefic::Plot.seed(&block)
  end
end
