@snapshots = nil
last_snapshot = nil

on_update do
  last_snapshot = nil
  if !@snapshots.nil?
    last_snapshot = @snapshots.save(entities)
  end
end

on_player_update do |actor|
  @snapshots ||= Snapshots.new(entities)
  if actor.scene.key == :active and actor[:testing] != true and !actor.last_order.nil? and actor.last_order.action.verb != :undo and !last_snapshot.nil?
    @snapshots.history.push last_snapshot
  end
end
