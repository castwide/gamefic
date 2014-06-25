class Container < Thing

end

options(Container, :not_enterable, :enterable)
options(Container, :opaque, :transparent)
options(Container, :open, :closed).default = :open
options(Container, :openable, :unopenable).default = :unopenable
