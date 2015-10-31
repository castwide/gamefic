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
  def self.expression *args
    Gamefic::Query::Expression.new *args
  end
  def self.many_children *args
    Gamefic::Query::ManyChildren.new *args
  end
  def self.ambiguous_children *args
    Gamefic::Query::AmbiguousChildren.new *args
  end
  def self.plural_children *args
    Gamefic::Query::PluralChildren.new *args
  end
end
