class Gamefic::Query::Available < Gamefic::Query::Base
  def context_from(subject)
    result = []
    top = subject.room || subject.parent
    unless top.nil?
      result.concat subquery_neighborly(top)
    end
    result - [subject]
  end

  def breadth
    5
  end
end

class Gamefic::Query::Room < Gamefic::Query::Base
  def context_from(subject)
    [subject.room]
  end

  def breadth
    2
  end
end
