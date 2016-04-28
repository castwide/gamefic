respond :show, Use.reachable(Character), Use.children do |actor, character, thing|
  actor.tell "#{The character} isn't interested in #{the thing}."
end

respond :show, Use.reachable, Use.children do |actor, witness, thing|
  actor.tell "Nothing happens."
end

respond :show, Use.children, Use.text do |actor, thing, text|
  actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.do + ' not'} see any \"#{text}\" here."
end

interpret "show :thing to :character", "show :character :thing"
