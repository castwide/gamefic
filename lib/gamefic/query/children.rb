module Gamefic::Query
  class Children < Base
    def base_specificity
      50
    end
    def context_from(subject)
      subject.children
    end
  end
  def self.children *args
    Children *args
  end
end
