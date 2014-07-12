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
# Sit is a shortcut for entering an enterable supporter.
respond :sit do |actor|
  supporters = actor.room.children.that_are(Supporter).that_are(:enterable)
  if supporters.length == 1
    actor.perform :enter, supporters[0]
  elsif supporters.length > 1
    actor.tell "I don't know where you want to sit: #{supporters.join_and(', ', ' or ')}."
  else
    actor.tell "There's nowhere to sit here."
  end
end

xlate "sit :thing", :enter, :thing
xlate "sit on :thing", :enter, :thing
xlate "get on :thing", :enter, :thing
xlate "get in :thing", :enter, :thing
xlate "stand on :thing", :enter, :thing
xlate "sit down", :sit
