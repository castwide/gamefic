respond :close, Query::Text.new() do |actor, string|
  actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.do + ' not'} see any \"#{string}\" here."
end

respond :close, Use.reachable() do |actor, thing|
  actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.can + ' not'} close #{the thing}."
end

respond :close, Use.reachable(Openable) do |actor, container|
  if !container.open?
    actor.tell "It's already closed."
  else
    actor.tell "#{you.pronoun.Subj} close #{the container}."
    container.open = false
  end
end
