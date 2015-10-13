require 'gamefic/query/children'

class Gamefic::Query::ManyChildren < Gamefic::Query::Children
  def allow_many?
    true
  end
end
