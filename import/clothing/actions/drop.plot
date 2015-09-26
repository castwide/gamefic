respond :drop, Query::Children.new(Clothing) do |actor, clothing|
  if clothing.attached?
    actor.perform :doff, clothing
  end
  if !clothing.attached?
    actor.proceed
  end
end
