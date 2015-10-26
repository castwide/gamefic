require 'snapshots'

meta :undo do |actor|
  last = @snapshots.history.pop
  if last.nil?
    actor.tell "No previous turns are available."
  else
    @snapshots.restore last
    actor.tell "Previous turn undone."
  end
end
