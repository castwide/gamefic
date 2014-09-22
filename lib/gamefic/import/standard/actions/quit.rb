yes_or_no :confirm_quit ,"Are you sure you want to quit?" do |actor, answer|
  if answer == 'yes'
    actor.state = :concluded
  else
    actor.state = :active
  end
end

meta :quit do |actor|
  actor.state = :confirm_quit
end
