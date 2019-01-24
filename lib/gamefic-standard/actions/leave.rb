Gamefic.script do
  respond :leave, Use.parent do |actor, thing|
    actor.tell "There's no way out of #{the thing}."
  end

  respond :leave, Use.parent(Enterable, :enterable?) do |actor, thing|
    actor.tell "#{you.pronoun.Subj} #{you.verb[thing.leave_verb]} #{the thing}."
    actor.parent = thing.parent
  end

  respond :leave, Use.room do |actor, room|
    portals = room.children.that_are(Portal)
    if portals.length == 0
      actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.do + ' not'} see any obvious exits."
    elsif portals.length == 1
      actor.perform :go, portals[0]
    else
      actor.tell "I don't know which way you want to go: #{portals.join_or}."
    end
  end

  respond :leave do |actor|
    actor.perform :leave, actor.parent
  end

  interpret "exit", "leave"
  interpret "exit :supporter", "leave :supporter"
  interpret "get on :supporter", "enter :supporter"
  interpret "get off :supporter", "leave :supporter"
  interpret "get out :container", "leave :container"
  interpret "get out of :container", "leave :container"
end
