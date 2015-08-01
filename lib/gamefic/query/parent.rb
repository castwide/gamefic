module Gamefic::Query
  class Parent < Base
    def base_specificity
      30
    end
    def context_from(subject)
      [subject.parent]
    end
  end
  def self.parent *args
    Parent.new *args
  end
end
