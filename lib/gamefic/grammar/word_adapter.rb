module Gamefic::Grammar
  module WordAdapter
    include Gender
    include Person
    include Plural

    # @return [Gamefic::Grammar::Pronouns]
    def pronoun
      @pronoun ||= Gamefic::Grammar::Pronouns.new(self)
    end

    # @return [Gamefic::Grammar::Verbs]
    def verb
      @verb ||= Gamefic::Grammar::Verbs.new(self)
    end

    def contract words
      contractions[words] || words
    end

    private

    def contractions
      if @contractions.nil?
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
          "does not" => "doesn't",
          "can not" => "can't"
        }
        capitalized = {}
        @contractions.each_pair { |k,v |
          if k[0] != k[0].capitalize
            capitalized[k.cap_first] = v.cap_first
          end
        }
        @contractions.merge! capitalized
      end
      @contractions
    end
  end
end
