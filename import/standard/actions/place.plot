respond :place, Use.children, Use.reachable do |actor, thing, supporter|
  actor.tell "You can't put #{the thing} on #{the supporter}."
end

respond :place, Use.visible, Use.reachable(Supporter) do |actor, thing, supporter|
  if thing.parent != actor
    actor.perform :take, thing
  end
  if thing.parent == actor
    actor.perform :drop_on, thing
  end
end

respond :place, Use.children, Use.reachable(Supporter) do |actor, thing, supporter|
  thing.parent = supporter
  actor.tell "You put #{the thing} on #{the supporter}."
end

respond :place, Use.visible, Use.text do |actor, thing, supporter|
  actor.tell "You don't see anything called \"#{supporter}\" here."
end

respond :place, Use.text, Use.visible do |actor, thing, supporter|
  actor.tell "You don't see anything called \"#{thing}\" here."
end

respond :place, Use.text, Use.text do |actor, thing, supporter|
  actor.tell "I don't know what you mean by \"#{thing}\" or \"#{supporter}.\""
end

xlate "put :thing on :supporter", "place :thing :supporter"
xlate "put :thing down on :supporter", "place :thing :supporter"
xlate "set :thing on :supporter", "place :thing :supporter"
xlate "set :thing down on :supporter", "place :thing :supporter"
xlate "drop :thing on :supporter", "place :thing :supporter"
xlate "place :thing on :supporter", "place :thing :supporter"
