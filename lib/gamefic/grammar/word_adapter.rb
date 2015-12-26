require 'gamefic/grammar'
require 'gamefic/grammar/gender'

module Gamefic::Grammar
  module WordAdapter
    include Gender
    include Person
    include Plural
    # @return [Gamefic::Grammar::Pronouns]
    def pronoun
      @pronoun ||= Grammar::Pronouns.new(self)
    end
    # @return [Gamefic::Grammar::Verbs]
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
      #src = verb.send(words)
      @contractions[words] || src
    end
  end
end
