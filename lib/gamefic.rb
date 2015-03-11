require "gamefic/core_ext/array"
require "gamefic/core_ext/string"
require "gamefic/optionset"
require "gamefic/keywords"
require "gamefic/entity"
require "gamefic/character"
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

module Gamefic
  GLOBAL_IMPORT_PATH = File.dirname(__FILE__) + "/../import/"
end
