# This query resolves to the subject's room, as opposed to the parent. It's
# useful for making sure you target the room instead of a container or a
# supporter.

module Gamefic::Query
  class Room < Query::Parent
    def context_from(subject)
      [subject.room]
    end
  end
  def self.room *args
    Room.new *args
  end
end
