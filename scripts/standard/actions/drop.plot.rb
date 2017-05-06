respond :drop, Query::Visible.new() do |actor, thing|
  if thing.parent != actor
    actor.tell "#{you.contract you.pronoun.Subj + ' ' + you.verb.be} not carrying #{the thing}."
  else
    actor.proceed
  end
end

respond :drop, Query::Children.new() do |actor, thing|
  if thing.sticky?
    actor.tell thing.sticky_message || "#{you.pronoun.Subj} #{you.verb.need} to keep #{the thing} for now."
  else
    thing.parent = actor.parent
    actor.tell "#{you.pronoun.Subj} drop #{the thing}."
  end
end

interpret "put down :thing", "drop :thing"
interpret "put :thing down", "drop :thing"
