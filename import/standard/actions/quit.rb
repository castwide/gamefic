yes_or_no :confirm_quit, "Are you sure you want to quit?" do |actor, data|
  if data.answer == "yes"
    cue actor, :concluded
  else
    cue actor, :active
  end
end

meta :quit do |actor|
  cue actor, :confirm_quit
end
