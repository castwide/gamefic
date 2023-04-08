# frozen_string_literal: true

require 'gamefic/version'
require 'gamefic/logging'
require 'gamefic/core_ext/array'
require 'gamefic/core_ext/string'
require 'gamefic/setup'
require 'gamefic/syntax'
require 'gamefic/response'
require 'gamefic/playbook'
require 'gamefic/scenebook'
require 'gamefic/query'
require 'gamefic/scanner'
require 'gamefic/scope'
require 'gamefic/command'
require 'gamefic/action'
require 'gamefic/scene'
require 'gamefic/take'
require 'gamefic/scriptable'
require 'gamefic/assembly'
require 'gamefic/plot'
require 'gamefic/subplot'
require 'gamefic/theater'
require 'gamefic/snapshot'
require 'gamefic/node'
require 'gamefic/describable'
require 'gamefic/messaging'
require 'gamefic/entity'
require 'gamefic/proxy'
require 'gamefic/dispatcher'
require 'gamefic/active'
require 'gamefic/active/cue'
require 'gamefic/actor'

module Gamefic
  # A shortcut to `Gamefic::Plot.script`
  #
  def self.script &block
    Gamefic::Plot.script &block
  end
end
