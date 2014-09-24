module Roughly
  XSMALL = 1
  SMALL = 2
  MEDIUM = 3
  LARGE = 4
  XLARGE = 5
end

class Entity
  attr_writer :size
  def size
    @size ||= (is?(:portable) ? Roughly::SMALL : Roughly::MEDIUM)
  end
end

class Room
  def size
    @size ||= Roughly::XLARGE
  end
end

respond :drop_in, Query::Children.new(), Query::Reachable.new(Container) do |actor, thing, container|
  if container.size <= thing.size
    actor.tell "#{The thing} can't fit in #{the container}."
  else
    passthru
  end
end

respond :drop_on, Query::Children.new(), Query::Reachable.new(Supporter) do |actor, thing, supporter|
  if supporter.size < thing.size
    actor.tell "#{The supporter} can't accommodate #{the thing}."
  else
    passthru
  end
end
