respond :inventory do |actor|
  if actor.children.length > 0
    actor.tell actor.children.join(', ')
  else
    actor.tell "You aren't carrying anything."
  end
end
xlate "i", :inventory
