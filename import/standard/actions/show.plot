respond :show, Query.reachable(Character), Query.children do |actor, character, thing|
  actor.tell "#{The character} isn't interested in #{the thing}."
end

respond :show, Query.reachable, Query.children do |actor, witness, thing|
  actor.tell "Nothing happens."
end

respond :show, Query.children, Query.text do |actor, thing, text|
  actor.tell "You don't see any \"#{text}\" here."
end

interpret "show :thing to :character", "show :character :thing"
