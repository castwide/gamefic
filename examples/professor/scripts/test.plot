script 'standard/test'

on_test :me do |actor, queue|
  queue.push "look around"
  queue.push "look professor"
  queue.push "talk to professor"
  queue.push "name"
  queue.push "ask professor about job"
end
