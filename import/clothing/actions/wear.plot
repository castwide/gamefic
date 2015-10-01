respond :wear, Query::Reachable.new(Clothing) do |actor, clothing|
  if clothing.parent != actor
    actor.perform "take #{clothing}"
  end
  if clothing.parent == actor
    if clothing.attached?
      actor.tell "You're already wearing #{the clothing}."
    else
      already = actor.children.that_are(clothing.class).that_are(:attached?)
      if already.length == 0
        clothing.attached = true
        actor.tell "You put on #{the clothing}."
      else
        actor.tell "You're already wearing #{an already[0]}."
      end
    end
  end
end

xlate "put on :clothing", "wear :clothing"
xlate "put :clothing on", "wear :clothing"
xlate "don :clothing", "wear :clothing"
