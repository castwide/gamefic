module You
  class GrammarSet
    include Gamefic::Grammar::Gender
    include Gamefic::Grammar::Person
    include Gamefic::Grammar::Plural
    include Gamefic::Grammar::WordAdapter

    def initialize
      self.person = 2
    end
  end

  # @return [You::GrammarSet]
  def you
    @you ||= GrammarSet.new
  end
end

class Gamefic::Plot
  include You
end

class Gamefic::Subplot
  include You
end
