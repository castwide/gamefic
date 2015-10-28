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
      # TODO: This routine is stubbed to allow any combination of letters and
      # numbers as a keyword. Since we're doing this, there's a distinct
      # possibility that the Keywords class can be deprecated.
      #self.delete_if { |w|
      #  w.length < 2 or w == 'an' or w == 'the'
      #}
      #self.uniq!
      self
    end
    def found_in(other, both_ways = false)
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
            elsif both_ways
              if my_word[0, other_word.length] == other_word and other_word.length > 2
                  matches = matches + (my_word.length.to_f / other_word.length.to_f)
              end
            end
          }
        end
      }
      return matches
    end
    def to_s
      self.join(' ')
    end
  end

end
