#require 'gamefic/keywords'

module Gamefic

  module Query
    autoload :Base, 'gamefic/query/base'
    autoload :Children, 'gamefic/query/children'
    autoload :Descendants, 'gamefic/query/descendants'
    autoload :Family, 'gamefic/query/family'
    autoload :Itself, 'gamefic/query/itself'
    autoload :Matches, 'gamefic/query/matches'
    autoload :Parent, 'gamefic/query/parent'
    autoload :Siblings, 'gamefic/query/siblings'
    autoload :Text, 'gamefic/query/text'

    # @todo Get rid of this
    class Self < Itself;end
  end

end
