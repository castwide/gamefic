module Gamefic
  module Grammar
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
    end
  end
end
