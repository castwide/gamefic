require 'gamefic/core_ext/array'
require 'gamefic/core_ext/string'

module Gamefic
  autoload :Grammar, 'gamefic/grammar'
  autoload :Keywords, 'gamefic/keywords'
  autoload :Serialized, 'gamefic/serialized'
  autoload :Entity, 'gamefic/entity'
  autoload :Character, 'gamefic/character'
end

require "gamefic/scene"
require "gamefic/scene/active"
require "gamefic/scene/concluded"
require "gamefic/scene/paused"
require "gamefic/scene/multiplechoice"
require "gamefic/scene/yesorno"
require "gamefic/action"
require "gamefic/meta"
require "gamefic/syntax"
require "gamefic/query"
require "gamefic/rule"
require "gamefic/director"
require "gamefic/plot"
require "gamefic/engine"
require "gamefic/direction"
require "gamefic/snapshots"
