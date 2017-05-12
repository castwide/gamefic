respond :inventory do |actor|
  if actor.children.length > 0
    carried = actor.children.that_are_not(:attached?)
    worn = actor.children.that_are(:attached?)
    if carried.length > 0
      actor.tell "You are carrying #{carried.join_and}."
    end
    if worn.length > 0
      actor.tell "You are wearing #{worn.join_and}."
    end
  else
    actor.tell "You aren't carrying anything."
  end
end
