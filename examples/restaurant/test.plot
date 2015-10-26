require 'standard/test'

on_test :me do |actor, queue|
  queue.push "n"
  queue.push "nw"
  queue.push "eat dinner"
  queue.push "se"
  queue.push "s"
  queue.push "w"
  queue.push "take jacket"
  queue.push "wear jacket"
  queue.push "e"
  queue.push "s"
end
