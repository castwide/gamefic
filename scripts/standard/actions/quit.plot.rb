confirm_quit = yes_or_no do |actor, data|
  if data.yes?
    actor.cue default_conclusion
  else
    actor.cue default_scene
  end
end

meta :quit do |actor|
  actor.tell "Are you sure you want to quit?"
  actor.cue confirm_quit
end
