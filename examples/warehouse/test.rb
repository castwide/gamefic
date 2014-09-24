import 'standard/tests'

on_test :me do |actor|
  actor.perform "look around"
  actor.perform "look desk"
  actor.perform "take key"
  actor.perform "n"
  actor.perform "unlock crate"
  actor.perform "open crate"
  actor.perform "take gold"
end
