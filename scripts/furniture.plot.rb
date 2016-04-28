class Gamefic::Seat < Gamefic::Entity
  include Enterable
  def initialize plot, args = {}
    self.enterable = true
    self.enter_verb = "sit on"
    self.leave_verb = "stand up from"
    self.inside_verb = "be sitting on"
    super
  end
end

respond :sit do |actor|
  seats = Use.reachable.context_from(actor).that_are(Seat)
  if seats.length == 1
    actor.perform :enter, seats[0]
  elsif seats.length > 1
    actor.tell "I don't know where you want to sit: #{seats.join_or}"
  else
    actor.tell "There's nowhere to sit here."
  end
end

respond :stand do |actor|
  if actor.parent == actor.room
    actor.tell "You're already standing."
  else
    actor.perform :leave, actor.parent
  end
end

interpret "sit :seat", "enter :seat"
interpret "sit on :seat", "enter :seat"
interpret "stand up from :seat", "leave :seat"
interpret "sit down", "sit"
interpret "stand up", "stand"
