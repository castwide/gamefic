require 'gamefic/grammar'

module Gamefic::Grammar
  module WordAdapter
    def pronoun
      @pronoun ||= Grammar::Pronouns.new(self)
    end
    def verb
      @verb ||= Grammar::Verbs.new(self)
    end
    def contract words
      @contractions ||= {
        "I am" => "I'm",
        "you are" => "you're",
        "he is" => "he's",
        "she is" => "she's",
        "it is" => "it's",
        "we are" => "we're",
        "they are" => "they're",
        "am not" => "am not",
        "are not" => "aren't",
        "is not" => "isn't",
        "do not" => "don't",
        "does not" => "doesn't"
      }
      src = pronoun.subj + " " + verb.send(words)
      @contractions[src] || src
    end
  end
end
