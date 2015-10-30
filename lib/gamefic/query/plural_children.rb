class Gamefic::Query::PluralChildren < Gamefic::Query::AmbiguousChildren
  def execute(subject, description)
    if !description.end_with?("s") and !description.end_with?("i") and !description.end_with?("ae")
      return Gamefic::Query::Matches.new([], '', description)
    end
    super
  end
  def validate(subject, object)
    # Plural queries always return false on validation. Their only purpose is
    # to provide syntactic sugar for plural nouns, so it should never get triggered
    # by a token call.
    false
  end
end
