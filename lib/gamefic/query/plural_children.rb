class Gamefic::Query::PluralChildren < Gamefic::Query::AmbiguousChildren
  def execute(subject, description)
    if !description.end_with?("s") and !description.end_with?("i") and !description.end_with?("ae")
      return Gamefic::Query::Matches.new([], '', description)
    end
    super
  end
end
