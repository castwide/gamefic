# @gamefic.script undo
#   UNDO action.

script 'snapshots'

meta :undo do |actor|
  snap = Snapshots.history.pop
  if snap.nil?
    actor.tell "Nothing to undo."
  else
    restore snap
    actor.tell "Last action undone."
  end
end
