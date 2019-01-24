Gamefic.script do
  respond :take, Use.text do |actor, text|
    actor.tell "#{you.pronoun.Subj} #{you.contract(you.verb.do + ' not')} see any \"#{text}\" here."
  end

  respond :take, Use.available do |actor, thing|
    if thing.parent == actor
      actor.tell "#{you.contract(you.pronoun.subj + ' are').cap_first} already carrying #{the thing}."
    elsif thing.portable?
      if actor.parent != thing.parent
        actor.tell "#{you.pronoun.Subj} #{you.verb.take} #{the thing} from #{the thing.parent}."
      else
        actor.tell "#{you.pronoun.Subj} #{you.verb.take} #{the thing}."
      end
      thing.parent = actor
    else
      actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.can + ' not'} take #{the thing}."
    end
  end

  respond :take, Use.available(:attached?) do |actor, thing|
    actor.tell "#{The thing} is attached to #{the thing.parent}."
  end

  respond :take, Use.available(Rubble) do |actor, rubble|
    actor.tell "#{you.pronoun.Subj} #{you.contract(you.verb.do + ' not')} have any use for #{the rubble}."
  end

  interpret "get :thing", "take :thing"
  interpret "pick up :thing", "take :thing"
  interpret "pick :thing up", "take :thing"
  interpret "carry :thing", "take :thing"
end
