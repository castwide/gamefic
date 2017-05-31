meta nil, Query::Text.new() do |actor, string|
  words = string.split_words
  list = verbs
  if list.include?(words[0])
    if words.length > 1
      actor.tell "I recognize '#{words[0]}' as a verb but could not understand the rest of your sentence."
    else
      actor.tell "I recognize '#{words[0]}' as a verb but could not understand it in this context."
    end
  else
    found = []
    list.each { |c|
      next if c.include?('_')
      if c.length > words[0].length and c.start_with?(words[0])
        found.push c
      end
    }
    if found.length == 1
      words[0] = found[0]
      actor.perform words.join(' ')
    elsif found.length > 1 and words[0].length > 2
      actor.tell "I'm not sure if #{words[0]} means #{found.join_and(', ', ' or ')}."
    else
      actor.tell "I don't recognize '#{words[0]}' as a verb."
    end
  end
end

meta nil, Query::Text.new(/^it$/) do |actor, string|
  words = string.split_words
  if verbs(to_s: true).include?(words[0])
    actor.tell "I'm not sure what you mean by \"it.\""
  else
    actor.proceed
  end
end
