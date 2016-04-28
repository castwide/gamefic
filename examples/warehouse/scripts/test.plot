script 'standard/test'

on_test :me do |actor, queue|
  queue.push "look around"
  queue.push "look desk"
  queue.push "take key"
  queue.push "n"
  queue.push "unlock crate"
  queue.push "open crate"
  queue.push "take gold"
end
