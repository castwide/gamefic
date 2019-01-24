Gamefic.script do
  respond :talk do |actor|
    actor.tell "#{you.pronoun.Subj} #{you.verb.talk} to #{you.pronoun.reflex}."
  end

  respond :talk, Use.itself do |actor, yourself|
    actor.perform :talk
  end

  respond :talk, Use.available do |actor, thing|
    actor.tell "Nothing happens."
  end

  respond :talk, Use.available(Character) do |actor, character|
    if actor == character
      actor.perform :talk
    else
      actor.tell "#{The character} has nothing to say."
    end
  end

  interpret "talk to :character", "talk :character"
  interpret "talk to :character about :subject", "talk :character :subject"
  interpret "ask :character :subject", "talk :character :subject"
  interpret "ask :character about :subject", "talk :character :subject"
  interpret "tell :character :subject", "talk :character :subject"
  interpret "tell :character about :subject", "talk :character :subject"
  interpret "ask :character for :subject", "talk :character :subject"
end
