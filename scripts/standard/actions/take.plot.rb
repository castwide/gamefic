respond :take, Use.reachable do |actor, thing|
  actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.can + ' not'} take #{the thing}."
end

respond :take, Use.visible do |actor, thing|
  if thing.parent == actor.parent
    actor.proceed
  elsif thing.parent.kind_of?(Container) and !thing.parent.open?
    actor.tell "#{The thing} is inside #{the thing.parent}, which is closed."
  end
end

respond :take, Use.visible do |actor, thing|
  if actor.parent.kind_of?(Supporter) and actor.parent != thing.parent and actor.parent != thing.parent.parent
    actor.tell "#{you.pronoun.Subj} can't reach it from #{the actor.parent}."
  else
    actor.proceed
  end
end

respond :take, Use.reachable(:attached?) do |actor, thing|
  actor.tell "#{The thing} is attached to #{the thing.parent}."
end

respond :take, Use.reachable(Entity, :portable?) do |actor, thing|
  if thing.parent == actor
    actor.tell "#{you.contract(you.pronoun.subj + ' are').cap_first} already carrying #{the thing}."
  else
    if actor.parent != thing.parent
      actor.tell "#{you.pronoun.Subj} #{you.verb.take} #{the thing} from #{the thing.parent}."
    else
      actor.tell "#{you.pronoun.Subj} #{you.verb.take} #{the thing}."
    end
    thing.parent = actor
  end
end

respond :take, Use.reachable(Rubble) do |actor, rubble|
  actor.tell "#{you.pronoun.Subj} #{you.contract(you.verb.do + ' not')} have any use for #{the rubble}."
end

respond :take, Use.text do |actor, text|
  actor.tell "#{you.pronoun.Subj} #{you.contract(you.verb.do + ' not')} see any \"#{text}\" here."
end

interpret "get :thing", "take :thing"
interpret "pick up :thing", "take :thing"
interpret "pick :thing up", "take :thing"
interpret "carry :thing", "take :thing"
