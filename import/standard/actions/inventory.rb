respond :inventory do |actor|
  if actor.children.length > 0
    actor.tell "You are carrying #{actor.children.join_and}."
  else
    actor.tell "You aren't carrying anything."
  end
end
xlate "i", :inventory
