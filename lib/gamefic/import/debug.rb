options Character, :not_debugging, :debugging

meta :debug do |actor|
  current = actor.is?(:debugging) ? 'ON' : 'OFF'
  actor.tell "Debugging is currently #{current}."
end

meta :debug, Query::Text.new() do |actor, selection|
  entered = selection.to_s.downcase
  if entered == 'on'
    actor.is :debugging
    actor.tell "Debugging is ON."
  elsif entered == 'off'
    actor.is :not_debugging
    actor.tell "Debugging is OFF."
  else
    actor.tell "'#{selection}' is not a recognized debug option."
  end
end

meta :options, Query::Text.new() do |actor, string|
  begin
    cls = Gamefic.const_get(string)
  rescue NameError
    actor.tell "I don't know what '#{string}' is."
    next
  end
  sets = get_all_option_sets_for(cls)
  opts = []
  actor.tell "Option sets for #{string} (and default):"
  sets.each { |set|
    actor.tell "  #{set.options.join_and(', ', ' or ')} (#{set.default})"
  }
end

meta :analyze, Query::Visible.new() do |actor, thing|
  actor.tell "#{The thing} is a #{thing.class.to_s.gsub(/Gamefic::/, '')}."
  sets = get_all_option_sets_for(thing.class)
  opts = []
  sets.each { |set|
    opts.push thing.option_from_set(set)
  }
  actor.tell "#{The thing} is #{opts.join_and}."
end

meta :analyze, Query::Room.new() do |actor, thing|
  actor.tell "#{The thing} is a #{thing.class.to_s.gsub(/Gamefic::/, '')}."
  sets = get_all_option_sets_for(thing.class)
  opts = []
  sets.each { |set|
    opts.push thing.option_from_set(set)
  }
  actor.tell "#{The thing} is #{opts.join_and}."
end
