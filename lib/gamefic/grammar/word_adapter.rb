require 'gamefic/grammar'

module Gamefic::Grammar
  module WordAdapter
    def pronoun #=> Grammar::Pronouns
      @pronoun ||= Grammar::Pronouns.new(self)
    end
    def verb
      @verb ||= Grammar::Verbs.new(self)
    end
    def contract infinitive
      @contractions ||= {
        "I am" => "I'm",
        "you are" => "you're",
        "he is" => "he's",
        "she is" => "she's",
        "it is" => "it's",
        "we are" => "we're",
        "they are" => "they're"
      }
      src = pronoun.subj + " " + verb.send(infinitive)
      @contractions[src] || src
    end
  end
end
