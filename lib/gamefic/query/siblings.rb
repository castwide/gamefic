module Gamefic::Query
  class Siblings < Base
    def base_specificity
      40
    end
    def context_from(subject)
      (subject.parent.children - [subject])
    end
  end
end
