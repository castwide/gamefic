module Gamefic::Grammar
  module Conjugator
    module ClassMethods
      @@conjugated_verbs = {}
      def conjugate infinitive, *forms
        @@conjugated_verbs[infinitive] = VerbSet.new(infinitive, *forms)
      end
      def conjugated_verbs
        @@conjugated_verbs
      end
    end
    def self.included(base)
      base.extend ClassMethods
    end
  end
end
