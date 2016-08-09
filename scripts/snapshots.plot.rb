module Snapshots
  def self.history
    @history ||= []
  end
end

last_snapshot = nil

on_player_ready do |actor|
  last_snapshot = save
end

on_player_update do |actor|
  if (actor.last_order.nil? or !actor.last_order.action.meta?) and !last_snapshot.nil?
    Snapshots.history.push last_snapshot
  end
end
