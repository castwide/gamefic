Gamefic.script do
  respond :inventory do |actor|
    if actor.children.length > 0
      actor.tell "#{you.pronoun.Subj} #{you.verb.be} carrying #{actor.children.join_and}."
    else
      actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.be + ' not'} carrying anything."
    end
  end

  interpret "i", "inventory"
end
