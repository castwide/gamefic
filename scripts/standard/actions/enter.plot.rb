respond :enter, Use.siblings do |actor, thing|
  actor.tell "#{The thing} #{you.contract "can not"} accommodate #{you.pronoun.obj}."
end

respond :enter, Use.siblings(Enterable, :enterable?) do |actor, supporter|
  actor.parent = supporter
  actor.tell "#{you.pronoun.Subj} #{you.verb[supporter.enter_verb]} #{the supporter}."
end

respond :enter, Use.parent do |actor, container|
  actor.tell "#{you.contract(you.pronoun.subj + ' ' + you.verb.be).cap_first} already in #{the container}."
end

respond :enter, Use.parent(Supporter) do |actor, supporter|
  actor.tell "#{you.pronoun.Subj} #{you.verb[supporter.enter_verb]} #{the supporter} already."
end

interpret "get on :thing", "enter :thing"
interpret "get in :thing", "enter :thing"
