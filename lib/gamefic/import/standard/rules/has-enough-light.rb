assert :has_enough_light do |actor|
  if actor.room.is? :lighted
    true
  else
    actor.tell "It's too dark in here."
    false
  end
end

# Allow the go command in dark rooms
before :go, Query::Siblings.new(Portal) do |actor, portal|
  pass :has_enough_light
  passthru
end
