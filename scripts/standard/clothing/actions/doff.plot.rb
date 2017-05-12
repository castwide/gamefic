respond :doff, Query::Children.new(Clothing) do |actor, clothing|
  if !clothing.attached?
    actor.tell "You're not wearing #{the clothing}."
  else
    clothing.attached = false
    actor.tell "You take off #{the clothing}."
  end
end

xlate "remove :clothing", "doff :clothing"
xlate "take off :clothing", "doff :clothing"
xlate "take :clothing off", "doff :clothing"
