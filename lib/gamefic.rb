require_relative "./gamefic/core_ext/array"
require_relative "./gamefic/core_ext/string"
require_relative "./gamefic/keywords"
require_relative "./gamefic/entity"
require_relative "./gamefic/character"
require_relative "./gamefic/action"
require_relative "./gamefic/syntax"
require_relative "./gamefic/query"
require_relative "./gamefic/director"
require_relative "./gamefic/plot"
require_relative "./gamefic/story"
require_relative "./gamefic/engine"
require_relative "./gamefic/user"

module Gamefic

	@@with_base = false
	def with_base?
		@@with_base
	end

end
