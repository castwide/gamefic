options Character, :not_debugging, :debugging

respond :debug do |actor|
    current = actor.is?(:debugging) ? 'ON' : 'OFF'
    actor.tell "Debugging is currently #{current}."
end

respond :debug, Query::Text.new() do |actor, selection|
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

respond :options, Query::Text.new() do |actor, string|
  begin
    cls = Gamefic.const_get(string)
  rescue NameError
    actor.tell "I don't know what '#{string}' is."
    next
  end
  sets = get_all_option_sets_for(cls)
  opts = []
  sets.each { |set|
    opts.push set.default
  }
  actor.tell "A default #{string} is #{opts.join_and}."
end

respond :options, Query::Visible.new() do |actor, thing|
  sets = get_all_option_sets_for(thing.class)
  opts = []
  sets.each { |set|
    opts.push thing.option_from(set)
  }
  actor.tell "#{The thing} is #{opts.join_and}."
end
