yes_or_no :confirm_quit, 'Are you sure you want to quit?' do |actor, data|
  if data.yes?
    actor.cue :concluded
  else
    actor.cue :active
  end
end

meta :quit do |actor|
  actor.cue :confirm_quit
end
