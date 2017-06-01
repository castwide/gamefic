# @gamefic.script save-restore-undo
#   SAVE, RESTORE, and UNDO actions.

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

respond :undo do |actor|
  snap = Snapshots.history.last
  if snap.nil?
    actor.tell "Nothing to undo."
  else
    restore snap
    actor.tell "Last action undone."
  end
end
