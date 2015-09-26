class Gamefic::Item < Gamefic::Thing
  def pre_initialize
    self.portable = true
  end
end
