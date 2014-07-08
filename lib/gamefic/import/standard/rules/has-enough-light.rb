assert :has_enough_light do |actor, action|
  if actor.room.is? :lighted
    true
  else
    if action == :go
      true
    else
      actor.tell "It's too dark in here."
      false
    end
  end
end
