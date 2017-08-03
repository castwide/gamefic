require 'gamefic/grammar'

module Gamefic::Grammar
  class Verbs
    extend Gamefic::Grammar::Conjugator::ClassMethods
    def initialize obj
      @pronoun = obj
      self.class.conjugated_verbs.each_pair { |infinitive, verbset|
        define_singleton_method infinitive do
          verbset[:present].conjugate @pronoun
        end
      }
    end
    def method_missing infinitive, *args, &block
      Gamefic::Grammar::VerbSet.new(infinitive, nil, *args).conjugate(@pronoun)
    end
    def [] infinitive
      words = infinitive.split_words
      Gamefic::Grammar::VerbSet.new(words[0], nil).conjugate(@pronoun) + (words.length > 1 ? ' ' + words[1..-1].join(' ') : '')
    end
    conjugate :be,   :present, :am,   :are,  :is,  :are
    conjugate :have, :present, :have, :have, :has, :have
    conjugate :can, :present, :can, :can, :can
  end
end
