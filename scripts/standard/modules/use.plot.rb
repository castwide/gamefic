module Use
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

  def self.available *args
    Gamefic::Query::Available.new *args
  end

  def self.reachable *args
    available *args
  end

  def self.visible *args
    available *args
  end

  def self.room *args
    Gamefic::Query::Room.new *args
  end

  def self.itself *args
    Gamefic::Query::Room.new *args
  end

  def self.from objects, *args
    Gamefic::Query::External.new objects, *args
  end
end
