respond :quit do |actor|
  actor.destroy
end
respond :commands do |actor|
  actor.tell actor.plot.commandwords.sort.join(", ")
end
