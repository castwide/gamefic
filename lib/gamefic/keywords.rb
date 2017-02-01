# Arrays of keywords that can be compared for matches.

module Gamefic

  class Keywords < Array
    def initialize(statement = '')
      if statement.kind_of?(Keywords)
        self.concat statement
      else
        if statement.kind_of?(Array)
          statement = statement.join(' ')
        end
        self.concat statement.to_s.gsub(/[^a-z0-9]/i, ' ').strip.downcase.split(' ')
      end
      self
    end

    # Count the number of matching words in another Keywords array.
    # The total includes partial matches; for example, "gre" is a 0.6 match
    # for "green".
    #
    # @return [Float] The total number of matches
    def found_in(other, fuzzy = false)
      matches = 0.0
      self.each { |my_word|
        if other.include?(my_word)
          matches = matches + 1.0
        else
          other.each { |other_word|
            if my_word.length < other_word.length
              if other_word[0, my_word.length] == my_word and my_word.length > 2
                matches = matches + (my_word.length.to_f / other_word.length.to_f)
              end
            elsif fuzzy
              fuzzy_word = fuzzify my_word
              if other_word[0, fuzzy_word.length] == fuzzy_word and fuzzy_word.length > 2
                matches = matches + (fuzzy_word.length.to_f / other_word.length.to_f)
              elsif fuzzy_word[0, other_word.length] == other_word and other_word.length > 2
                matches = matches + (fuzzy_word.length.to_f / other_word.length.to_f)
              end
            end
          }
        end
      }
      matches
    end

    def to_s
      self.join(' ')
    end

    private
    
    def fuzzify word
      if word.end_with?('ies')
        word[0..-4]
      elsif word.end_with?('ae')
        word[0..-3]
      elsif word.end_with?('s') or word.end_with?('i')
        word[0..-2]
      else
        word
      end
    end
  end

end
