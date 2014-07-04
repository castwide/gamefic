class Container < Thing
  attr_accessor :unlocker
end

options(Container, :not_enterable, :enterable)
options(Container, :opaque, :transparent)
options(Container, :open, :closed).default = :open
options(Container, :openable, :unopenable).default = :unopenable
options(Container, :unlocked, :locked)
options(Container, :not_lockable, :lockable)
set_default_for(Container, :not_portable)
