script 'snapshots'

meta :save do |actor|
  actor.perform :save, "game.sav"
end

meta :save, Query::Text.new() do |actor, filename|
  actor.user.save filename, @snapshots.save(entities)
end

meta :restore do |actor|
  actor.perform :restore, "game.sav"
end

meta :restore, Query::Text.new() do |actor, filename|
  data = actor.user.restore(filename)
  if !data.nil?
    @snapshots.restore data
    actor.tell "Game restored."
  end
end
