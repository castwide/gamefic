respond :what, Query::Text.new do |actor, question|
  actor.tell "It looks like you're asking a question. Try giving a command instead. Use HELP for more information."
end

respond :what, Query::Reachable.new do |actor, thing|
  actor.tell "It looks like you want information about #{the thing}. Try looking at it."
end

xlate "where :question", "what :question"
xlate "when :question", "what :question"
xlate "why :question", "what :question"
xlate "who :question", "what :question"

xlate "what is :thing", "look :thing"
xlate "what's :thing", "look :thing"
xlate "who is :thing", "look :thing"
xlate "who's :thing", "look :thing"
