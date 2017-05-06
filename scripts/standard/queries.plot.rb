#script 'standard/queries/reachable'
#script 'standard/queries/room'
#script 'standard/queries/visible'
#script 'standard/queries/from_expression'

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
