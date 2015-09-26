module Gamefic::Query
  class Text < Base
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
      args = Keywords.new(@arguments)
      found = Array.new
      remainder = Array.new
      keywords.each { |key|
        if args.include?(key)
          found.push key
        else
          remainder.push key
        end
      }
      if found.length > 0
        return Matches.new([description], found.join(' '), remainder.join(' '))
      else
        return Matches.new([], '', description)
      end
    end
    def test_arguments arguments
      # No test for text
    end
  end
end
