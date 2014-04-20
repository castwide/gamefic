# Before Actions are processed before Rules. Their primary use is to determine
# whether or not a particular Action (or thread of Actions) should be allowed
# to happen. A Before Action's proc can use the pass and deny methods to
# override the results of rule assertions.

module Gamefic

  class Before < Action

  end

end
