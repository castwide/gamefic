module Gamefic::Query
  class Base
    @@ignored_words = ['a', 'an', 'the', 'and', ',']
    @@subquery_prepositions = ['in', 'on', 'of', 'inside', 'from']
    # Include is necessary here due to a strange namespace
    # resolution bug when interpreting gfic files
    include Gamefic
    attr_accessor :arguments
    def initialize *arguments
      test_arguments arguments
      @optional = false
      if arguments.include?(:optional)
        @optional = true
        arguments.delete :optional
      end
      @arguments = arguments
      @match_hash = Hash.new
    end
    # Check whether the query allows ambiguous matches.
    # If allowed, this query's 
    def allow_ambiguous?
      false
    end
    def allow_many?
      false
    end
    def last_match_for(subject)
      @match_hash[subject]
    end
    def optional?
      @optional
    end
    def context_from(subject)
      subject
    end
    def validate(subject, object)
      arr = context_from(subject)
      @arguments.each { |arg|
        arr = arr.that_are(arg)
      }
      if (allow_many? or allow_ambiguous?)
        if object.kind_of?(Array)
          return (object & arr) == object
        end
        return false
      elsif !object.kind_of?(Array)
        return arr.include?(object)
      end
      return false
    end
    # @return [Array]
    def execute(subject, description)
      if (allow_many? or allow_ambiguous?) and !Query.allow_plurals?
        return Matches.new([], '', description)
      end
      if !allow_ambiguous?
        if allow_many? and !description.include?(',') and !description.downcase.include?(' and ')
          return Matches.new([], '', description)
        end
      end
      array = context_from(subject)
      matches = self.match(description, array)
      objects = matches.objects
      matches = Matches.new(objects, matches.matching_text, matches.remainder)
      if objects.length == 0 and matches.remainder == "it" and subject.respond_to?(:last_object)
        if !subject.last_object.nil?
          obj = subject.last_object
          if validate(subject, obj)
            matches = Matches.new([obj], "it", "")
          end
        end
      end
      @match_hash[subject] = matches
      matches
    end
    def base_specificity
      0
    end
    def specificity
      if @specificity == nil
        @specificity = base_specificity
        magnitude = 1
        @arguments.each { |item|
          if item.kind_of?(Entity)
            @specificity += (magnitude * 10)
            item = item.class
          end
          if item.kind_of?(Class)
            s = item
            while s != nil
              @specificity += magnitude
              s = s.superclass
            end
          else
            @specificity += magnitude
          end
        }
        if allow_many?
          # HACK Ridiculously high magic number to force queries that return
          # arrays to take precedence over everything
          @specificity = @specificity * 10
        end
      end
      @specificity
    end
    def signature
      "#{self.class}(#{@arguments.join(',')})"
    end
    def test_arguments arguments
      my_classes = [Gamefic::Entity]
      my_objects = []
      arguments.each { |a|
        if a.kind_of?(Class) or a.kind_of?(Module)
          my_classes.push a
        elsif a.kind_of?(Gamefic::Entity)
          my_objects.push a
        elsif a.kind_of?(Symbol)
          if my_classes.length == 0 and my_objects.length == 0
            raise ArgumentError.new("Query signature requires at least one class, module, or object to accept a method symbol")
          end
          if my_classes.length > 0
            responds = false
            my_classes.each { |c|
              if c.instance_methods.include?(a)
                responds = true
                break
              end
            }
            if !responds
              raise ArgumentError.new("Query signature does not have a target that responds to #{a}")
            end
          end
          my_objects.each { |o|
            if !o.respond_to?(a)
              raise ArgumentError.new("Query signature contains object '#{o}' that does not respond to '#{a}'")
            end
          }
        else
          raise ArgumentError.new("Invalid argument '#{a}' in query signature")
        end
      }
    end
    def match(description, array)
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
          if !at_least_one_match
            return Matches.new([], '', description)
          end
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
        new_results = []
        most_matches = 0.0
        possibilities.each { |p|
          words = Keywords.new(used.last)
          if words.length > 0
            matches = words.found_in(p.keywords, (allow_many? or allow_ambiguous?))
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
        elsif (next_word.downcase == 'and' or next_word == ',')
          while keywords.first == ',' or keywords.first.downcase == 'and'
            used.push keywords.shift
          end
          if allow_ambiguous?
            # Ambiguous queries filter based on all keywords instead of
            # building an array of specified entities
            next
          end
          so_far = keywords.join(' ')
          recursed = self.match(so_far, array)
          if possibilities.length == 1 and !allow_ambiguous?
            possibilities = [possibilities]
          else
            # Force lists of things to be uniquely identifying
            return Matches.new([], '', description)
          end
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
end
