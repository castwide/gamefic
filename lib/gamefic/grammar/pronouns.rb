require 'gamefic'
require 'gamefic/grammar'

module Gamefic::Grammar
  class Pronouns
    def initialize object
      @object = object
    end
    def subj
      Pronouns.get_pronoun_set(@object)[0]
    end
    def obj
      Pronouns.get_pronoun_set(@object)[1]
    end
    def poss
      Pronouns.get_pronoun_set(@object)[2]
    end
    def reflex
      Pronouns.get_pronoun_set(@object)[3]
    end
    def Subj
      subj.cap_first
    end
    def Obj
      obj.cap_first
    end
    def Poss
      obj.cap_first
    end
    def Reflex
      reflex.cap_first
    end
    def self.get_pronoun_set(obj)
      set = Pronouns.sets["#{obj.person}"]
      if set.nil?
        set = Pronouns.sets["#{obj.person}:#{obj.plural? ? 'plural' : 'singular'}"]
      end
      if set.nil?
        set = Pronouns.sets["#{obj.person}:#{obj.plural? ? 'plural' : 'singular'}:#{obj.gender}"]
      end
      if set.nil?
        raise "Pronoun set could not be determined"
      end
      set
    end
    # TODO Consider implementing method_missing to determine correct pronoun
    # from example, e.g., "he" would change to "she" for female entities
    def self.sets
      if @sets.nil?
        @sets = {}
        @sets["1:singular"] = ["I", "me", "my", "myself"]
        @sets["2"] = ["you", "you", "your", "yourself"]
        @sets["3:singular:male"] = ["he", "him", "his", "himself"]
        @sets["3:singular:female"] = ["she", "her", "her", "herself"]
        # "other" refers to a person or living being that is neither
        # male or female or for whom gender is unspecified. It's
        # typically used to avoid referring to a person as "it."
        @sets["3:singular:other"] = ["they", "them", "their", "themselves"]
        @sets["3:singular:neutral"] = ["it", "it", "its", "itself"]
        @sets["1:plural"] = ["we", "us", "our", "ourselves"]
        @sets["3:plural"] = ["they", "them", "their", "themselves"]
      end
      @sets
    end
  end
end
