import 'standard/tests'

on_test :me do |actor|
  actor.perform "s"
  actor.perform "n"
  actor.perform "w"
  actor.perform "inventory"
  actor.perform "hang cloak on hook"
  actor.perform "e"
  actor.perform "s"
  actor.perform "read message"
end
