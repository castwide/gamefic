require "gamefic/keywords"

module Gamefic

  module Query
    autoload :Base, 'gamefic/query/base'
    autoload :Text, 'gamefic/query/text'
    autoload :Self, 'gamefic/query/self'
    autoload :Parent, 'gamefic/query/parent'
    autoload :Children, 'gamefic/query/children'
    autoload :ManyChildren, 'gamefic/query/many_children'
    autoload :Siblings, 'gamefic/query/siblings'
    autoload :Family, 'gamefic/query/family'
    autoload :Subquery, 'gamefic/query/subquery'
    autoload :Matches, 'gamefic/query/matches'
    
    @@ignored_words = ['a', 'an', 'the']
    @@subquery_prepositions = ['in', 'on', 'of', 'inside', 'from']
    
    def self.last_new
      Base.last_new
    end

    def self.match(description, array)
      keywords = description.split_words
      array.each { |e|
        if e.uid == keywords[0]
          return Matches.new([e], keywords.shift, keywords.join(' '))
        end
      }
      used = []
      skipped = []
      possibilities = array
      at_least_one_match = false
      while keywords.length > 0
        next_word = keywords.shift
        if @@subquery_prepositions.include?(next_word)
          so_far = keywords.join(' ')
          in_matched = self.match(so_far, array)
          if in_matched.objects.length == 1
            # Subset matching should only consider the intersection of the
            # original array and the matched object's children. This ensures
            # that it won't erroneously match a child that was excluded from
            # the original query.
            subset = self.match(used.join(' '), (array & in_matched.objects[0].children))
            if subset.objects.length == 1
              return subset
            end
          end
        end
        used.push next_word
        next if @@ignored_words.include?(next_word)
        new_results = []
        most_matches = 0.0
        possibilities.each { |p|
          words = Keywords.new(used.last)
          if words.length > 0
            matches = words.found_in(p.keywords)
            if matches > 0
              new_results.push p
              most_matches = matches
            end
          end
        }
        if new_results.length > 0
          at_least_one_match = true
          intersection = possibilities & new_results
          if intersection.length == 0
            skipped.push used.pop
            #return Matches.new(possibilities, used.join(' '), skipped.join(' '))
          else
            skipped.clear
            possibilities = intersection
          end
          if next_word.end_with?(',')
            so_far = keywords.join(' ')
            recursed = self.match(so_far, array)
            possibilities += recursed.objects
            possibilities.uniq!
            used = recursed.matching_text.split_words
            skipped = recursed.remainder.split_words
            keywords = []
          end
        elsif next_word == 'and'
          so_far = keywords.join(' ')
          recursed = self.match(so_far, array)
          possibilities += recursed.objects
          possibilities.uniq!
          used = recursed.matching_text.split_words
          skipped = recursed.remainder.split_words
          keywords = []
        else
          skipped.push used.pop
          # The first unignored word must have at least one match
          if !at_least_one_match
            return Matches.new([], '', description)
          end
        end
      end
      if at_least_one_match and (used - @@ignored_words).length > 0
        return Matches.new(possibilities, used.join(' '), skipped.join(' '))
      else
        return Matches.new([], '', description)
      end
    end
  end
  module Use
  end
end
