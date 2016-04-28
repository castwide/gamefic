script 'standard/queries/many_visible'

class Gamefic::Query::AmbiguousVisible < Gamefic::Query::ManyVisible
  def allow_ambiguous?
    true
  end
end

module Gamefic::Use
  def self.ambiguous_visible *args
    Gamefic::Query::AmbiguousVisible.new *args
  end
end
