script 'snapshots'

meta :undo do |actor|
  last = Snapshots.history.pop
  if last.nil?
    actor.tell "No previous turns are available."
  else
    restore last
    actor.tell "Previous turn undone."
  end
end
