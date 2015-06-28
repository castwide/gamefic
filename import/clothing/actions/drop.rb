respond :drop, Query::Children.new(Clothing, :worn) do |actor, clothing|
  actor.perform :doff, clothing
  if !clothing.is?(:worn)
    actor.proceed
  end
end
