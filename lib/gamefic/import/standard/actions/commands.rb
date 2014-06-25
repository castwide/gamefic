meta :commands do |actor|
  actor.tell actor.plot.commandwords.sort.join(", ")
end
