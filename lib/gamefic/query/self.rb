module Gamefic::Query
  class Self < Base
    def base_specificity
      30
    end
    def context_from(subject)
      [subject]
    end
  end
  def self.itself *args
    Self.new *args
  end
end
