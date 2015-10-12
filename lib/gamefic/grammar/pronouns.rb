require 'gamefic'
require 'gamefic/grammar'

module Gamefic::Grammar
  class Pronouns
    attr_reader :subj, :obj, :poss
    # i, you, he, she, it, we, you, they
    def initialize obj # TODO What does this take?
      # We need a person and (optionally) a plurality and gender      
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
      @subj = set[0]
      @obj = set[1]
      @poss = set[2]
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
    # TODO Consider implementing method_missing to determine correct pronoun
    # from example, e.g., "he" would change to "she" for female entities
    def self.sets
      if @sets.nil?
        @sets = {}
        @sets["1:singular"] = ["I", "me", "my"]
        @sets["2"] = ["you", "you", "your"]
        @sets["3:singular:male"] = ["he", "him", "his"]
        @sets["3:singular:female"] = ["she", "her", "her"]
        # "other" refers to a person or living being that is neither
        # male or female or for whom gender is unspecified. It's
        # typically used to avoid referring to a person as "it."
        @sets["3:singular:other"] = ["they", "them", "their"]
        @sets["3:singular:neutral"] = ["it", "it", "its"]
        @sets["1:plural"] = ["we", "us", "our"]
        @sets["3:plural"] = ["they", "them", "their"]
      end
      @sets
    end
  end
end
