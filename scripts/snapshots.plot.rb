module Snapshots
  def self.history
    @history ||= []
  end
end

last_snapshot = nil

on_player_ready do |actor|
  if (actor.last_action.nil? or !actor.last_action.meta?) and !last_snapshot.nil?
    Snapshots.history.push last_snapshot
  end
  last_snapshot = save
end
