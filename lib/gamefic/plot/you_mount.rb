require 'gamefic-core'
require 'gamefic/grammar'

module Gamefic
  module Plot::YouMount
    class YouGrammarSet
      include Grammar::Gender
      include Grammar::Person
      include Grammar::Plural
      include Grammar::WordAdapter
    end
    # @return [YouGrammarSet]
    def you
      if @you.nil?
        @you = YouGrammarSet.new
        @you.person = 2
      end
      @you
    end
  end
  
end
