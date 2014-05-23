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
