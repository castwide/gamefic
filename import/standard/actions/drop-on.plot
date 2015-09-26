respond :drop_on, Query::Children.new(), Query::Reachable.new() do |actor, thing, supporter|
  actor.tell "You can't put #{the thing} on #{the supporter}."
end

respond :drop_on, Query::Visible.new(), Query::Reachable.new(Supporter) do |actor, thing, supporter|
  if thing.parent != actor
    actor.perform :take, thing
  end
  if thing.parent == actor
    actor.perform :drop_on, thing
  end
end

respond :drop_on, Query::Children.new(), Query::Reachable.new(Supporter) do |actor, thing, supporter|
  thing.parent = supporter
  actor.tell "You put #{the thing} on #{the supporter}."
end

respond :drop_on, Query::Visible.new(), Query::Text.new() do |actor, thing, supporter|
  actor.tell "You don't see anything called \"#{supporter}\" here."
end

respond :drop_on, Query::Text.new(), Query::Visible.new() do |actor, thing, supporter|
  actor.tell "You don't see anything called \"#{thing}\" here."
end

respond :drop_on, Query::Text.new(), Query::Text.new() do |actor, thing, supporter|
  actor.tell "I don't know what you mean by \"#{thing}\" or \"#{supporter}.\""
end

xlate "put :thing on :supporter", "drop_on :thing :supporter"
xlate "put :thing down on :supporter", "drop_on :thing :supporter"
xlate "set :thing on :supporter", "drop_on :thing :supporter"
xlate "set :thing down on :supporter", "drop_on :thing :supporter"
xlate "drop :thing on :supporter", "drop_on :thing :supporter"
xlate "place :thing on :supporter", "drop_on :thing :supporter"
