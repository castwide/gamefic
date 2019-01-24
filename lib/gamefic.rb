require 'gamefic/version'

require 'gamefic/keywords'
require 'gamefic/core_ext/array'
require 'gamefic/core_ext/string'

require 'gamefic/grammar'
require 'gamefic/describable'
require 'gamefic/element'
require 'gamefic/entity'
require 'gamefic/active'
require 'gamefic/actor'
require "gamefic/scene"
require "gamefic/query"
require "gamefic/action"
require "gamefic/syntax"
require 'gamefic/world'
require "gamefic/plot"
require 'gamefic/subplot'
require "gamefic/engine"
require "gamefic/user"

module Gamefic
  class << self
    def scripts
      @scripts ||= []
    end

    def script &block
      scripts.push block
    end
  end
end
