class Gamefic::Query::AmbiguousChildren < Gamefic::Query::ManyChildren
  def allow_ambiguous?
    true
  end
end
