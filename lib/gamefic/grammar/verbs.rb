require 'gamefic'
require 'gamefic/grammar'

module Gamefic::Grammar
  class Verbs
    extend Conjugator::ClassMethods
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
    def [] infinitive
      VerbSet.new(infinitive, nil, *args).conjugate(@pronoun)
    end
    conjugate :be,   :present, :am,   :are,  :is,  :are
    conjugate :have, :present, :have, :have, :has, :have
  end
end
