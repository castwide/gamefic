class Gamefic::Item < Gamefic::Entity
  def pre_initialize
    self.portable = true
  end
end
