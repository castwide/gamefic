require 'standard/test'

on_test :me do |actor, queue|
  queue.push "s"
  queue.push "n"
  queue.push "w"
  queue.push "inventory"
  queue.push "hang cloak on hook"
  queue.push "e"
  queue.push "s"
  queue.push "read message"
end
