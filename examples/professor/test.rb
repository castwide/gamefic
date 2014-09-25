import 'standard/test'

on_test :me do |actor|
  actor.perform "look around"
  actor.perform "look professor"
  actor.perform "talk to professor"
  actor.perform "name"
  actor.perform "ask professor about job"
end
