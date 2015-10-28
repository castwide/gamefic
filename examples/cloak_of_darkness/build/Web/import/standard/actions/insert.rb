require 'gamefic';module Gamefic;respond :insert, Use.visible, Use.reachable do |actor, thing, target|
  actor.tell "You can't put #{the thing} inside #{the target}."
end

respond :insert, Use.visible, Use.reachable(Receptacle) do |actor, thing, receptacle|
  if actor.auto_takes?(thing)
    actor.tell "You put #{the thing} in #{the receptacle}."
    thing.parent = receptacle
  end
end

respond :insert, Use.visible, Use.reachable(Container) do |actor, thing, container|
  if container.open?
    actor.proceed
  else
    actor.tell "#{The container} is closed."
  end
end

respond :insert, Use.visible, Use.text do |actor, thing, container|
  actor.tell "You don't see anything called \"#{container}\" here."
end

respond :insert, Use.text, Use.visible do |actor, thing, container|
  actor.tell "You don't see anything called \"#{thing}\" here."
end

respond :insert, Use.text, Use.text do |actor, thing, container|
  actor.tell "I don't know what you mean by \"#{thing}\" or \"#{container}.\""
end

interpret "drop :item in :container", "insert :item :container"
interpret "put :item in :container", "insert :item :container"
interpret "place :item in :container", "insert :item :container"
interpret "insert :item in :container", "insert :item :container"

interpret "drop :item inside :container", "insert :item :container"
interpret "put :item inside :container", "insert :item :container"
interpret "place :item inside :container", "insert :item :container"
interpret "insert :item inside :container", "insert :item :container"

interpret "drop :item into :container", "insert :item :container"
interpret "put :item into :container", "insert :item :container"
interpret "place :item into :container", "insert :item :container"
interpret "insert :item into :container", "insert :item :container"
;end
