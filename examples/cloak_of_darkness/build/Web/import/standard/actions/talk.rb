require 'gamefic';module Gamefic;respond :talk do |actor|
  actor.tell "You talk to yourself."
end

respond :talk, Query::Self.new do |actor, yourself|
  actor.perform :talk
end

respond :talk, Query::Reachable.new do |actor, thing|
  actor.tell "Nothing happens."
end

respond :talk, Query::Reachable.new(Character) do |actor, character|
  if actor == character
    actor.perform :talk
  else
    actor.tell "#{The character} has nothing to say."
  end
end

respond :talk, Query::Reachable.new(Character), Query::Text.new do |actor, character, text|
  actor.perform :talk, character
end

xlate "talk to :character", "talk :character"
xlate "talk to :character about :subject", "talk :character :subject"
xlate "ask :character :subject", "talk :character :subject"
xlate "ask :character about :subject", "talk :character :subject"
xlate "tell :character :subject", "talk :character :subject"
xlate "tell :character about :subject", "talk :character :subject"
xlate "ask :character for :subject", "talk :character :subject"
;end
