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

respond :give, Query::Reachable.new(Character), Query::Children.new do |actor, character, gift|
  actor.tell "#{The character} doesn't want #{the gift}."
end

respond :give, Query::Text.new, Query::Children.new do |actor, character, gift|
  actor.tell "You don't see any \"#{character}\" here."
end

xlate "give :gift to :character", "give :character :gift"
