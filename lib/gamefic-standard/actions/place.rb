Gamefic.script do
  respond :place, Use.children, Use.reachable do |actor, thing, supporter|
    actor.tell "#{you.pronoun.Subj} #{you.contract(you.verb.can + ' not')} put #{the thing} on #{the supporter}."
  end

  respond :place, Use.visible, Use.reachable(Supporter) do |actor, thing, supporter|
    if thing.parent != actor
      actor.perform :take, thing
    end
    if thing.parent == actor
      thing.parent = supporter
      actor.tell "You put #{the thing} on #{the supporter}."
    end
  end

  respond :place, Use.children, Use.reachable(Supporter) do |actor, thing, supporter|
    if thing.sticky?
      actor.tell thing.sticky_message || "#{you.pronoun.Subj} #{you.verb.need} to keep #{the thing} for now."
    else
      thing.parent = supporter
      actor.tell "#{you.pronoun.Subj} #{you.verb.put} #{the thing} on #{the supporter}."
    end
  end

  respond :place, Use.visible, Use.text do |actor, thing, supporter|
    actor.tell "#{you.pronoun.Subj} #{you.contract(you.verb.do + ' not')} see anything called \"#{supporter}\" here."
  end

  respond :place, Use.text, Use.visible do |actor, thing, supporter|
    actor.tell "#{you.pronoun.Subj} #{you.contract(you.verb.do + ' not')} see anything called \"#{thing}\" here."
  end

  respond :place, Use.text, Use.text do |actor, thing, supporter|
    actor.tell "I don't know what you mean by \"#{thing}\" or \"#{supporter}.\""
  end

  xlate "put :thing on :supporter", "place :thing :supporter"
  xlate "put :thing down on :supporter", "place :thing :supporter"
  xlate "set :thing on :supporter", "place :thing :supporter"
  xlate "set :thing down on :supporter", "place :thing :supporter"
  xlate "drop :thing on :supporter", "place :thing :supporter"
  xlate "place :thing on :supporter", "place :thing :supporter"
end
