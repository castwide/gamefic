script 'standard'

respond :insert, Use.visible, Use.reachable do |actor, thing, target|
  actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.can + ' not'} put #{the thing} inside #{the target}."
end

respond :insert, Use.visible, Use.reachable(Receptacle) do |actor, thing, receptacle|
  if thing.sticky?
    actor.tell thing.sticky_message || "#{you.pronoun.Subj} #{you.verb.need} to keep #{the thing} for now."
  else
    if actor.auto_takes?(thing)
      actor.tell "#{you.pronoun.Subj} put #{the thing} in #{the receptacle}."
      thing.parent = receptacle
    end
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
  actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.do + ' not'} see anything called \"#{container}\" here."
end

respond :insert, Use.text, Use.visible do |actor, thing, container|
  actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.do + ' not'} see anything called \"#{thing}\" here."
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
