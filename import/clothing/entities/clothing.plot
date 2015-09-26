import 'standard/entities/item'

class Gamefic::Clothing < Gamefic::Item
  def worn?
    self.parent.kind_of?(Character) and self.attached?
  end
end
