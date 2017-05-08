respond :talk do |actor|
  actor.tell "#{you.pronoun.Subj} #{you.verb.talk} to #{you.pronoun.reflex}."
end

respond :talk, Use.itself do |actor, yourself|
  actor.perform :talk
end

respond :talk, Use.family do |actor, thing|
  actor.tell "Nothing happens."
end

respond :talk, Use.family(Character) do |actor, character|
  if actor == character
    actor.perform :talk
  else
    actor.tell "#{The character} has nothing to say."
  end
end

respond :talk, Use.family(Character), Query::Text.new do |actor, character, text|
  actor.perform :talk, character
end

xlate "talk to :character", "talk :character"
xlate "talk to :character about :subject", "talk :character :subject"
xlate "ask :character :subject", "talk :character :subject"
xlate "ask :character about :subject", "talk :character :subject"
xlate "tell :character :subject", "talk :character :subject"
xlate "tell :character about :subject", "talk :character :subject"
xlate "ask :character for :subject", "talk :character :subject"
