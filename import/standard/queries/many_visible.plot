require 'standard/queries/visible'

class Gamefic::Query::ManyVisible < Gamefic::Query::Visible
  def allow_many?
    true
  end  
end

module Gamefic::Use
  def self.many_visible *args
    Gamefic::Query::ManyVisible.new *args
  end
end
