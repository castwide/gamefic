meta :quit do |actor|
  actor.state = GameOverState.new(actor)
end
