meta :commands do |actor|
  actor.tell "This game understands the following commands: #{actor.plot.commandwords.sort.join_and}."
end
