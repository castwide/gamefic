import 'standard/entities/item'

class Gamefic::Clothing < Item
  def parent=(entity)
    super
    # Clothing should always become :not_worn when its parent changes.
    is :not_worn
  end
end

options(Clothing, :not_worn, :worn)
