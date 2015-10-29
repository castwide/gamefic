require 'gamefic/keywords'

module Gamefic

  module Query
    autoload :Base, 'gamefic/query/base'
    autoload :Text, 'gamefic/query/text'
    autoload :Expression, 'gamefic/query/expression'
    autoload :Self, 'gamefic/query/self'
    autoload :Parent, 'gamefic/query/parent'
    autoload :Children, 'gamefic/query/children'
    autoload :ManyChildren, 'gamefic/query/many_children'
    autoload :AmbiguousChildren, 'gamefic/query/ambiguous_children'
    autoload :PluralChildren, 'gamefic/query/plural_children'
    autoload :Siblings, 'gamefic/query/siblings'
    autoload :Family, 'gamefic/query/family'
    autoload :Subquery, 'gamefic/query/subquery'
    autoload :Matches, 'gamefic/query/matches'
    
    @@ignored_words = ['a', 'an', 'the', 'and', ',']
    @@subquery_prepositions = ['in', 'on', 'of', 'inside', 'from']
    
    def self.last_new
      Base.last_new
    end

    def self.match(description, array, ambiguous = false)
      if description.include?(',')
        tmp = description.split(',', -1)
        keywords = []
        first = tmp.shift
        if first.strip != ''
          keywords.push first.strip
        end
        tmp.each { |t|
          keywords.push ','
          if t.strip != ''
            keywords += t.strip.split_words
          end
        }
        keywords = keywords.join(' ').split_words
      else
        keywords = description.split_words
      end
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
          if in_matched.objects.length > 0 and (in_matched.objects.length == 1 or in_matched.objects[0].kind_of?(Array))
            # Subset matching should only consider the intersection of the
            # original array and the matched object's children. This ensures
            # that it won't erroneously match a child that was excluded from
            # the original query.
            parent = in_matched.objects.shift
            subset = self.match(used.join(' '), (array & (parent.kind_of?(Array) ? parent[0].children : parent.children)))
            if subset.objects.length == 1
              if in_matched.objects.length == 0
                return subset
              else
                return Matches.new([subset.objects] + in_matched.objects, subset.matching_text, subset.remainder)
              end
            end
          end
        end
        used.push next_word
        #next if @@ignored_words.include?(next_word)
        new_results = []
        most_matches = 0.0
        possibilities.each { |p|
          words = Keywords.new(used.last)
          if words.length > 0
            matches = words.found_in(p.keywords, ambiguous)
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
          else
            skipped.clear
            possibilities = intersection
          end
        elsif !ambiguous and (next_word.downcase == 'and' or next_word == ',')
          while keywords.first == ',' or keywords.first.downcase == 'and'
            used.push keywords.shift
          end
          so_far = keywords.join(' ')
          recursed = self.match(so_far, array)
          possibilities = [possibilities]
          objects = recursed.objects.clone
          while objects.length > 0
            obj = objects.shift
            if obj.kind_of?(Array)
              possibilities.push obj
            else
              combined = [obj] + objects
              possibilities.push combined
              break
            end
          end
          used += recursed.matching_text.split_words
          skipped = recursed.remainder.split_words
          keywords = []
        else
          # The first unignored word must have at least one match
          if at_least_one_match and !@@ignored_words.include?(used.last)
            keywords.unshift used.pop
            return Matches.new(possibilities, used.join(' '), keywords.join(' '))
          else
            if !@@ignored_words.include?(used.last)
              return Matches.new([], '', description)
            end
          end
        end
      end
      if at_least_one_match and (used - @@ignored_words).length > 0
        r = Matches.new(possibilities, used.join(' '), skipped.join(' '))
        return r
      else
        return Matches.new([], '', description)
      end
    end
  end
  module Use
  end
end
