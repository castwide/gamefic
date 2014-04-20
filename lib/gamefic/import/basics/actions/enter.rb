respond :enter, Query::Siblings.new(Supporter, :enterable) do |actor, supporter|
  actor.parent = supporter
  actor.tell "You get on #{the supporter}."
end
respond :enter, Query::Siblings.new(Container, :enterable) do |actor, container|
  actor.parent = container
  actor.tell "You get in #{the container}."
end
respond :enter, Query::Siblings.new(Thing) do |actor, thing|
  actor.tell "#{The thing} can't accommodate you."
end
xlate "sit :thing", :enter, :thing
xlate "sit on :thing", :enter, :thing
xlate "get on :thing", :enter, :thing
xlate "get in :thing", :enter, :thing
xlate "stand on :thing", :enter, :thing
