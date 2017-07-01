require 'gamefic-core'
require 'gamefic/grammar'

module Gamefic::Grammar
  module Conjugator    
    module ClassMethods
      @@conjugated_verbs = {}
      def conjugate infinitive, tense, *forms
        @@conjugated_verbs[infinitive] ||= {}
        @@conjugated_verbs[infinitive][tense] = VerbSet.new(infinitive, *forms)
      end
      def conjugated_verbs
        @@conjugated_verbs
      end
    end
    #def self.included(base)
    #  base.extend ClassMethods
    #end
  end
end
