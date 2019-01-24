module Articles

  # Get a name for the entity with an indefinite article (unless the entity
  # has a proper name).
  #
  # @param entity [Gamefic::Entity]
  # @return [String]
  def a(entity)
    entity.indefinitely
  end

  # Alias for a.
  #
  # @param entity [Gamefic::Entity]
  # @return [String]
  def an(entity)
    entity.indefinitely
  end

  # Get a name for the entity with a definite article (unless the entity has
  # a proper name).
  #
  # @param entity [Gamefic::Entity]
  # @return [String]
  def the(entity)
    entity.definitely
  end

  # Get a capitalized name for the entity with an indefinite article (unless
  # the entity has a proper name).
  #
  # @param entity [Gamefic::Entity]
  # @return [String]
  def A(entity)
    entity.indefinitely.cap_first
  end

  # Alias for A.
  #
  # @param entity [Gamefic::Entity]
  # @return [String]
  def An(entity)
    entity.indefinitely.cap_first
  end

  # Get a capitalized name for the entity with a definite article (unless
  # the entity has a proper name).
  #
  # @param entity [Gamefic::Entity]
  # @return [String]
  def The(entity)
    entity.definitely.cap_first
  end
end

class Gamefic::Plot
  include Articles
end

class Gamefic::Subplot
  include Articles
end
