module Gamefic::Query
  class Family < Base
    def base_specificity
      40
    end
    def context_from(subject)
      subject.children + subject.parent.children #+ [subject.parent]
    end
  end
end
