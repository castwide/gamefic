module Gamefic::Query
  class Expression < Base
    def base_specificity
      10
    end
    def validate(subject, description)
      return false unless description.kind_of?(String)
      valid = false
      words = description.split_words
      words.each { |word|
        if description.include?(word)
          valid = true
          break
        end
      }
      valid
    end
    def execute(subject, description)
      if @arguments.length == 0
        return Matches.new([description], description, '')
      end
      keywords = Keywords.new(description)
      possible = []
      @arguments.each { |regexp|
        remainder = keywords.clone
        used = []
        while remainder.length > 0
          used.push remainder.shift
          if used.join(' ').match(regexp)
            possible.push Matches.new([used.join(' ')], used.join(' '), remainder.join(' '))
          end        
        end
      }
      if possible.length > 0
        possible.sort! { |a, b|
         b.matching_text.length <=> a.matching_text.length
        }
        return possible[0]
      else
        return Matches.new([], '', description)
      end
    end
    def test_arguments arguments
      # No test for text
    end
  end
end
