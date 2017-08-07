# @gamefic.script save-restore-undo
#   SAVE and RESTORE actions.

script 'snapshots'

respond :save do |actor|
  snap = save
  actor.user.save 'save.dat', snap
  actor.tell "Game saved."
end

respond :restore do |actor|
  actor.user.restore 'save.dat'
  actor.tell "Game restored."
end
