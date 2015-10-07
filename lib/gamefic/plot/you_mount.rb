require 'gamefic'
require 'gamefic/grammar'

module Gamefic
  module YouMount
    class YouGrammarSet
      include Grammar::Gender
      include Grammar::Person
      include Grammar::Plural
      include Grammar::WordAdapter
    end
    def you
      if @you.nil?
        @you = YouGrammarSet.new
        @you.person = 2
      end
    end
  end
  
end
