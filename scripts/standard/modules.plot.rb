# The StandardMethods module provides a namespace to define additional methods
# for plots and subplots. Examples include the `connect` method for creating
# portals between rooms.
#
module StandardMethods
  include Gamefic::World
end

class Gamefic::Container
  include StandardMethods
end

script 'standard/modules/use'
script 'standard/modules/attachable'
script 'standard/modules/auto_takes'
script 'standard/modules/enterable'
script 'standard/modules/explicit_exits'
script 'standard/modules/itemizable'
script 'standard/modules/parent-room'
script 'standard/modules/portable'
script 'standard/modules/locale_description'
