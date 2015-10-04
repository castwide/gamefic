require 'gamefic/grammar'

module Gamefic::Grammar
  class Verbs
    include Conjugator
    def initialize obj
      @pronoun = obj
      self.class.conjugated_verbs.each_pair { |infinitive, verbset|
        define_singleton_method infinitive do
          verbset.conjugate @pronoun
        end
      }
    end
    def method_missing infinitive, *args, &block
      VerbSet.new(infinitive, nil, *args).conjugate(@pronoun)
    end
  end
end
