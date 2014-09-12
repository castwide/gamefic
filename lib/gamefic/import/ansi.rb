meta :ansi do |actor|
  actor.tell "Ansi is #{ansi ? 'ON' : 'OFF'}."
end

meta :ansi, Query::Text.new('on') do |actor, string|
  actor.ansi = true
  actor.tell "Ansi is ON."
end

meta :ansi, Query::Text.new('off') do |actor, string|
  actor.ansi = false
  actor.tell "Ansi is OFF."
end
