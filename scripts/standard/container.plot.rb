# @gamefic.script standard/container

script 'standard/openable'
script 'standard/lockable'
#script 'standard/container/entities'
#script 'standard/container/actions'

class Container < Receptacle
  include Openable
  include Lockable
  #include Transparent
end

respond :insert, Use.available, Use.available(Container) do |actor, thing, container|
  if container.open?
    actor.proceed
  else
    actor.tell "#{The container} is closed."
  end
end

respond :leave, Use.parent(Container, :enterable?, :closed?) do |actor, container|
  actor.tell "#{The container} is closed."
end

respond :enter, Use.siblings(Container, :enterable?, :closed?) do |actor, container|
  actor.tell "#{The container} is closed."
end
