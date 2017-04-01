script 'standard/entities/item'

class Clothing < Item
  def worn?
    self.parent.kind_of?(Character) and self.attached?
  end
end
