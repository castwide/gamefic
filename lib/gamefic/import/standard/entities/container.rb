class Container < Thing
  attr_accessor :key
end

options(Container, :not_enterable, :enterable)
options(Container, :opaque, :transparent)
options(Container, :open, :closed, :locked).default = :open
options(Container, :not_openable, :openable)
options(Container, :not_lockable, :lockable)
options(Container, :assumably_keyed, :not_assumably_keyed)
set_default_for(Container, :not_portable)
