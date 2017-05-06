module Gamefic::Use
  class RoomQuery < Gamefic::Query::Base
    def context_from(subject)
      [subject.room]
    end
    def breadth
      2
    end
  end
  def self.children *args
    Gamefic::Query::Children.new *args
  end
  def self.family *args
    Gamefic::Query::Family.new *args
  end
  def self.parent *args
    Gamefic::Query::Parent.new *args
  end
  def self.siblings *args
    Gamefic::Query::Siblings.new *args
  end
  def self.text *args
    Gamefic::Query::Text.new *args
  end
  def self.visible *args
    Gamefic::Query::Family.new *args
  end
  def self.reachable *args
    Gamefic::Query::Family.new *args
  end
  def self.available *args
    Gamefic::Query::Available.new *args
  end
  def self.room *args
    RoomQuery.new *args
  end
end
