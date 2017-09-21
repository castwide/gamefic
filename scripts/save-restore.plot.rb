# @gamefic.script save-restore
#   SAVE and RESTORE actions.

script 'snapshots'

meta :save do |actor|
  snap = save
  actor.user.save 'save.dat', snap
  actor.tell "Game saved."
end

meta :restore do |actor|
  actor.user.restore 'save.dat'
  actor.tell "Game restored."
end
