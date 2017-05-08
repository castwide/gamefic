class Gamefic::Query::Available < Gamefic::Query::Base
  def context_from(subject)
    result = []
    top = subject.room || subject.parent
    unless top.nil?
      result.concat subquery_accessible(top)
    end
    result.delete subject
    subject.children.each { |c|
      result.push c
      result.concat subquery_accessible(c)
    }
    result
  end

  def magnification
    1
  end
end

class Gamefic::Query::Room < Gamefic::Query::Base
  def context_from(subject)
    subject.room ? [subject.room] : []
  end

  def magnification
    4
  end
end
