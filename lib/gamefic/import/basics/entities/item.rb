import 'basics/entities/itemized'
import 'basics/entities/portable'

class Item < Entity
  include Itemized
  include Portable
end
