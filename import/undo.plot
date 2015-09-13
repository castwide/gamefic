import 'snapshots'

meta :undo do |actor|
  ss = Snapshots.history.pop
  if !ss.nil?
    Snapshots.restore(ss, self)
    actor.tell "Previous turn undone."
  else
    actor.tell "Previous turn is not available."
  end
end
