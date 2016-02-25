respond :use, Query::Reachable.new do |actor, tool|
  actor.tell "I don't know how to use #{the tool}. (A more specific command might work.)"
end

respond :use, Gamefic::Query::Text.new do |actor, thing|
  actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.do + ' not'} see any '#{thing}' #{you.pronoun.subj} can use here."
end

respond :use, Query::Reachable.new, Query::Reachable.new do |actor, tool, object|
  actor.tell "#{you.contract you.pronoun.Subj + ' ' + you.verb.be} not carrying the #{tool}."
end

respond :use, Gamefic::Query::Children.new, Gamefic::Query::Text.new do |actor, tool, object|
  actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.do + ' not'} see any '#{object}' here."
end

respond :use, Query::Text.new, Query::Reachable.new do |actor, tool, object|
  actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.do + ' not'} have anything called '#{tool}.'"
end

respond :use, Query::Children.new, Query::Reachable.new do |actor, tool, object|
  actor.tell "I don't know how to use #{the tool} on #{the object}. (A more specific command might work.)"
end

xlate "use :tool on :object", "use :tool :object"
