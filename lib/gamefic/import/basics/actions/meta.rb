respond :quit do |actor|
  actor.state = GameOverState.new(actor)
end
respond :commands do |actor|
  actor.tell actor.plot.commandwords.sort.join(", ")
end
