class Container < Thing
  attr_reader :key
  def key=(entity)
    @key = entity
    if !@key.nil?
      is :openable, :lockable
    end
  end
end

options(Container, :not_enterable, :enterable)
options(Container, :opaque, :transparent)
options(Container, :open, :closed, :locked).default = :open
options(Container, :not_openable, :openable)
options(Container, :not_lockable, :lockable)
options(Container, :auto_lockable, :not_auto_lockable)
set_default_for(Container, :not_portable)
