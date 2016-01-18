respond :look, Use.parent(Supporter) do |actor, supporter|
  actor.tell supporter.description
  actor.tell "#{you.pronoun.Subj} are currently on #{the supporter}."
end

respond :look, Query::Self.new do |actor, _|
  actor.tell actor.description
  actor.perform :inventory
end

respond :look, Use.room do |actor, room|
  actor.tell "<strong>#{room.name.cap_first}</strong>"
  actor.tell room.description
  with_locales = []
  chars = room.children.that_are(Character).that_are(:itemized?) - [actor]
  charsum = []
  chars.each { |char|
    if char.locale_description != ""
      with_locales.push char
    else
      charsum.push char
    end
  }
  if charsum.length > 0
    actor.tell "#{charsum.join_and.cap_first} #{charsum.length == 1 ? 'is' : 'are'} here."
  end
  items = room.children.that_are(:itemized?) - [actor] - room.children.that_are(Character) - room.children.that_are(Portal)
  itemsum = []
  items.each { |item|
    if item.locale_description != ""
      with_locales.push item
    else
      itemsum.push item
    end
  }
  if itemsum.length > 0
    actor.tell "#{you.pronoun.Subj} #{you.verb.see} #{itemsum.join_and}."
  end
  with_locales.each { |entity|
    actor.tell entity.locale_description
  }
  if room.explicit_exits?
    portals = room.children.that_are(Portal).that_are(:itemized?)
    if portals.length > 0
      if portals.length == 1
        actor.tell "There is an exit #{portals[0].direction}."
      else
        dirs = []
        portals.each { |p|
          dirs.push p.direction
        }
        actor.tell "There are exits #{dirs.join_and(', ')}."
      end
    end
  end
  if actor.parent.kind_of?(Supporter)
    actor.tell "#{you.pronoun.Subj} #{you.verb.be} on #{the actor.parent}."
    actor.parent.children.that_are_not(actor).each { |s|
      actor.tell "#{A s} is on #{the actor.parent}."
    }
  end
end
xlate "look", "look around"
xlate "l", "look around"

respond :look, Query::Visible.new() do |actor, thing|
  actor.tell thing.description
  thing.children.that_are(:attached?).that_are(:itemized?).each { |item|
    actor.tell "#{An item} is attached to #{the thing}."
  }
end

respond :look, Use.text do |actor, string|
  actor.tell "You don't see any \"#{string}\" here."
end

respond :look, Use.reachable(Receptacle) do |actor, receptacle|
  if receptacle.has_description?
    actor.tell receptacle.description
  end
  actor.perform :search, receptacle
end

respond :look, Query::Visible.new(Supporter) do |actor, supporter|
  actor.proceed
  supported = supporter.children.that_are_not(:attached?)
  if supported.length > 0
    actor.tell "You see #{supported.join_and} sitting there."
  end
end

respond :look, Query::Reachable.new(Door) do |actor, door|
  if door.has_description?
    actor.proceed
  end
  actor.tell "#{The door} is " + (door.open? ? 'open' : 'closed') + '.'
end

interpret "look at :thing", "look :thing"
interpret "l :thing", "look :thing"
interpret "examine :thing", "look :thing"
interpret "x :thing", "look :thing"
