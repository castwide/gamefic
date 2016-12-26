respond :give, Query::Reachable.new(Character), Query::Reachable.new do |actor, character, gift|
  if gift.parent != actor
    actor.perform :take, gift
  end
  if gift.parent == actor
    actor.perform :give, character, gift
  end
end

respond :give, Query::Reachable.new, Query::Children.new do |actor, character, gift|
  actor.tell "Nothing happens."
end

respond :give, Query::Reachable.new, Query::Reachable.new do |actor, character, gift|
  actor.tell "#{you.pronoun.Subj} #{you.contract(you.verb.do + ' not')} have #{the gift}."
end

respond :give, Query::Reachable.new(Character), Query::Children.new do |actor, character, gift|
  if gift.sticky?
    actor.tell gift.sticky_message || "#{you.pronoun.Subj} #{you.verb.need} to keep #{the gift} for now."
  else
    actor.tell "#{The character} doesn't want #{the gift}."
  end
end

respond :give, Query::Text.new, Query::Children.new do |actor, character, gift|
  actor.tell "#{you.pronoun.Subj} #{you.contract(you.verb.do + ' not')} see any \"#{character}\" here."
end

xlate "give :gift to :character", "give :character :gift"
