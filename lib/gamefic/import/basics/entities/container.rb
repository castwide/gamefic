class Container < Thing

end

options(Container, :enterable).default = :not_enterable
options(Container, :opaque, :transparent).default = :opaque
options(Container, :open, :closed).default = :open
options(Container, :openable, :unopenable).default = :unopenable
