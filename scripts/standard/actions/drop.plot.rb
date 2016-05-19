respond :drop, Query::Visible.new() do |actor, thing|
  actor.tell "#{you.contract you.pronoun.Subj + ' ' + you.verb.be} not carrying #{the thing}."
end

respond :drop, Query::Children.new() do |actor, thing|
  thing.parent = actor.parent
  actor.tell "#{you.pronoun.Subj} drop #{the thing}."
end

interpret "put down :thing", "drop :thing"
interpret "put :thing down", "drop :thing"
