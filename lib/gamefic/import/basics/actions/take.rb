respond :take, Query::Text.new() do |actor, thing|
  actor.tell "I don't see anything called '#{thing}' here."
end

respond :take, Query::Reachable.new(Entity, :not_portable) do |actor, thing|
  actor.tell "You can't take #{the thing}."
end

respond :take, Query::Siblings.new(Thing, :portable) do |actor, thing|
  thing.parent = actor
  actor.tell "You take #{the thing}."
end

respond :take, Query::Siblings.new() do |actor, thing|
  actor.tell "You can't carry #{the thing}."
end

respond :take, Query::Visible.new(Thing) do |actor, thing|
  if thing.parent == actor.parent
    passthru
  elsif thing.parent.is?(:closed)
    actor.tell "#{The thing} is inside #{the thing.parent}, which is closed."
  end
end

respond :take, Query::Visible.new(Thing) do |actor, thing|
  if actor.is? :supported
    if actor.parent != thing.parent and actor.parent != thing.parent.parent
      actor.tell "You can't reach it from #{the actor.parent}."
    end
  end
end

respond :take, Query::Reachable.new(Thing, :attached) do |actor, thing|
  actor.tell "#{The thing} is attached to #{the thing.parent}."
end

respond :take, Query::Reachable.new(Thing, :portable, :contained) do |actor, thing|
  if thing.parent != actor.parent
    if thing.parent.is?(:open) == false
      if thing.parent.is?(:transparent)
        actor.tell "#{The thing} is closed."
      else
        passthru
      end
      break
    end
    actor.tell "You take #{the thing} from #{the thing.parent}."
    thing.parent = actor
  else
    passthru
  end
end

respond :take, Query::Reachable.new(Thing, :portable, :supported) do |actor, thing|
  actor.tell "You take #{the thing} from #{the thing.parent}."
  thing.parent = actor
end

xlate "get :thing", :take, :thing
xlate "pick up :thing", :take, :thing
xlate "pick :thing up", :take, :thing

# The :take_from actions make it a little easier to disambiguate things. For
# example, if there's a green key in the room and a red key in a box, any of
# the following will understand which key you mean:
#   * take green key
#   * take red key
#   * take key from room
#   * take key from box
respond :take_from, Query::Room.new(), Query::Siblings.new() do |actor, container, thing|
  actor.perform "take #{thing}"
end
respond :take_from, Query::Reachable.new(Container, :closed), Query::Text.new() do |actor, container, thing|
  actor.tell "#{The container} is closed."
end
respond :take_from, Query::Reachable.new(Container, :open), Query::Subquery.new(Thing, :contained) do |actor, container, thing|
  actor.perform "take #{thing}"
end
respond :take_from, Query::Reachable.new(Container, :open), Query::Subquery.new(Thing, :attached) do |actor, container, thing|
  actor.tell "#{The thing} is attached to #{the container}."
end
respond :take_from, Query::Reachable.new(Supporter), Query::Subquery.new(Thing, :supported) do |actor, container, thing|
  actor.perform "take #{thing}"
end
xlate "take :thing from :container", :take_from, :container, :thing
xlate "get :thing from :container", :take_from, :container, :thing
xlate "pick :thing up from :container", :take_from, :container, :thing
xlate "pick up :thing from :container", :take_from, :container, :thing
xlate "take :thing in :container", :take_from, :container, :thing
xlate "get :thing in :container", :take_from, :container, :thing
xlate "pick :thing up in :container", :take_from, :container, :thing
xlate "pick up :thing in :container", :take_from, :container, :thing
xlate "take :thing on :container", :take_from, :container, :thing
xlate "get :thing on :container", :take_from, :container, :thing
xlate "pick :thing up on :container", :take_from, :container, :thing
xlate "pick up :thing on :container", :take_from, :container, :thing
xlate "take :thing inside :container", :take_from, :container, :thing
xlate "get :thing inside :container", :take_from, :container, :thing
xlate "pick :thing up inside :container", :take_from, :container, :thing
xlate "pick up :thing inside :container", :take_from, :container, :thing
