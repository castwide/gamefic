class Container < Thing

end

OptionSet.new(Container, :enterable).default = :not_enterable
OptionSet.new(Container, :opaque, :transparent).default = :opaque
OptionSet.new(Container, :open, :closed).default = :open
OptionSet.new(Container, :openable, :unopenable).default = :unopenable
