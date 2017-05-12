module Openable
  attr_writer :openable
  def open= bool
    @open = bool
  end
  def open?
    @open ||= false
  end
  def closed?
    !open?
  end
  def accessible?
    open?
  end
end

respond :open, Use.available do |actor, thing|
  actor.tell "You can't open #{the thing}."
end

respond :open, Use.available(Openable) do |actor, thing|
  if thing.open?
    actor.tell "#{The thing} is already open."
  else
    actor.tell "You open #{the thing}."
    thing.open = true
  end
end

respond :close, Use.available do |actor, thing|
  actor.tell "You can't close #{the thing}."
end

respond :close, Use.available(Openable) do |actor, thing|
  if thing.open?
    actor.tell "You close #{the thing}."
    thing.open = false
  else
    actor.tell "#{The thing} is already open."
  end
end
