
respond :wear, Query::Reachable.new(Clothing) do |actor, clothing|
  if clothing.parent != actor
    actor.perform "take #{clothing}"
  end
  if clothing.parent == actor
    if clothing.is?(:worn)
      actor.tell "You're already wearing #{the clothing}."
    else
      clothing.is :worn
      actor.tell "You put on #{the clothing}."
    end
  end
end

xlate "put on :clothing", :wear, :clothing
xlate "put :clothing on", :wear, :clothing
xlate "don :clothing", :wear, :clothing
