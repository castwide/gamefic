require "gamefic/keywords"

module Gamefic

  module Query

    @@ignored_words = ['a', 'an', 'the']
    @@subquery_prepositions = ['in', 'on', 'of', 'inside', 'from']

    def self.last_new
      Base.last_new
    end
    
    class Base
      @@last_new = nil
      attr_accessor :arguments
      def self.last_new
        @@last_new
      end
      def initialize *arguments
        @optional = false
        if arguments.include?(:optional)
          @optional = true
          arguments.delete :optional
        end
        @arguments = arguments
        @@last_new = self
        @match_hash = Hash.new
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
        array = context_from(subject)
        @arguments.each { |arg|
          array = array.that_are(arg)
        }
        return array.include?(object)
      end
      def execute(subject, description)
        array = context_from(subject)
        matches = Query.match(description, array)
        objects = matches.objects
        @arguments.each { |arg|
          objects = objects.that_are(arg)
        }
        matches = Matches.new(objects, matches.matching_text, matches.remainder)
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
            #magnitude = magnitude * 10
          }
        end
        @specificity
      end
      def signature
        return "#{self.class}(#{@arguments.join(',')})"
      end
    end
    
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
    end

    class Self < Base
      def base_specificity
        30
      end
      def context_from(subject)
        [subject]
      end
    end

    class Parent < Base
      def base_specificity
        30
      end
      def context_from(subject)
        [subject.parent]
      end
    end
    
    class Children < Base
      def base_specificity
        50
      end
      def context_from(subject)
        subject.children
      end
    end
    
    class Siblings < Base
      def base_specificity
        40
      end
      def context_from(subject)
        (subject.parent.children - [subject])
      end
    end
    
    class Family < Base
      def base_specificity
        40
      end
      def context_from(subject)
        subject.children + subject.parent.children #+ [subject.parent]
      end
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
          in_matched = self.match(keywords.join(' '), array)
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
        else
          skipped.push used.pop
        end
      end
      if at_least_one_match
        return Matches.new(possibilities, used.join(' '), skipped.join(' '))
      else
        return Matches.new([], '', description)
      end
    end
    
    class Subquery < Base
      def base_specificity
        40
      end
      def initialize *arguments
        if arguments[0].kind_of?(Query::Base)
          @parent = arguments.shift
        else
          @parent = Query.last_new
        end
        super
      end
      def context_from(subject)
        last = @parent.last_match_for(subject)
        return [] if last.nil? or last.objects.length != 1
        last.objects[0].children
      end
    end

		class Matches
			attr_reader :objects, :matching_text, :remainder
			def initialize(objects, matching_text, remainder)
				@objects = objects
				@matching_text = matching_text
				@remainder = remainder
        @@last_match = self
			end
		end

  end

end
