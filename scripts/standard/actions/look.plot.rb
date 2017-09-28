respond :look, Use.text do |actor, string|
  if string == 'around'
    actor.perform :look, actor.room
  else
    actor.tell "You don't see any \"#{string}\" here."
  end
end

respond :look, Use.itself do |actor, thing|
  actor.tell actor.description
  actor.perform :inventory
end

respond :look, Use.available(Thing) do |actor, thing|
  actor.tell thing.description
  thing.children.that_are(:attached?).that_are(:itemized?).each { |item|
    actor.tell "#{An item} is attached to #{the thing}."
  }
end

respond :look, Use.available(Supporter) do |actor, thing|
  if thing.accessible?
    itemized = thing.children.that_are_not(:attached?).that_are(:itemized?)
    # If the supporter does not have a description but it does contain
    # itemized things, avoid saying there's nothing special about it.
    actor.proceed if thing.has_description? or itemized.empty?
    actor.tell "You see #{itemized.join_and} on #{the thing}." unless itemized.empty?
  else
    actor.proceed
  end
end

respond :look, Use.available(Receptacle) do |actor, thing|
  actor.proceed
  if thing.accessible?
    itemized = thing.children.that_are_not(:attached?).that_are(:itemized?)
    actor.tell "You see #{itemized.join_and} in #{the thing}." unless itemized.empty?
  end
end

respond :look, Use.parent(Supporter, :enterable?) do |actor, supporter|
  actor.proceed
  actor.tell "#{you.pronoun.Subj} are currently on #{the supporter}."
end

respond :look, Use.room do |actor, room|
  actor.tell "<strong>#{room.name.cap_first}</strong>"
  actor.tell room.description if room.has_description?
  actor.execute :_itemize_room
end

respond :_itemize_room do |actor|
  room = actor.room
  next if room.nil?
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
        p = portals[0]
        actor.tell "There is an exit #{p.instruction}."
      else
        dirs = []
        portals.each { |p|
          dirs.push p.instruction
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

interpret "look", "look around"
interpret "l", "look around"

interpret "look at :thing", "look :thing"
interpret "l :thing", "look :thing"
interpret "examine :thing", "look :thing"
interpret "x :thing", "look :thing"
