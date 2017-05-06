module Gamefic::Use
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

  # @todo This query is a candidate for deprecation. It's probably not worth
  # the trouble to maintain a separate query just for transparent containers.
  #
  def self.visible *args
    Gamefic::Query::Family.new *args
  end

  # @todo This query is a candidate for deprecation. For now it's an alias for
  # Use.available.
  #
  def self.reachable *args
    Gamefic::Query::Available.new *args
  end

  def self.available *args
    Gamefic::Query::Available.new *args
  end

  def self.room *args
    Gamefic::Query::Room.new *args
  end
end
