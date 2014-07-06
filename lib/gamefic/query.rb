require "gamefic/keywords"

module Gamefic

  module Query

    class Base
      attr_accessor :arguments
      def initialize *arguments
        @optional = false
        if arguments.include?(:optional)
          @optional = true
          arguments.delete :optional
        end
        @arguments = arguments
      end
      def optional?
        @optional
      end
      def context_from(subject)
        subject
      end
      def execute(subject, description)
        array = context_from(subject)
        @arguments.each { |arg|
          array = array.that_are(arg)
        }
        return Query.match(description, array)
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
        used.push keywords.shift
        new_results = []
        most_matches = 0.0
        possibilities.each { |p|
          words = Keywords.new(used.last)
          if words.length > 0
            matches = words.found_in(p.keywords)
            if matches >= most_matches and matches > 0
              if matches - most_matches > 0.5
                new_results = []
              end
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
      def context_from(subject)
        last = Matches.last_match
        return [] if last.nil?
        last.children
      end
    end

		class Matches
      @@last_match = nil
			attr_reader :objects, :matching_text, :remainder
			def initialize(objects, matching_text, remainder)
				@objects = objects
				@matching_text = matching_text
				@remainder = remainder
        @@last_match = self
			end
      def self.last_match
        return nil if @@last_match.nil?
        if @@last_match.objects.length == 1
          return @@last_match.objects[0]
        end
        return nil
      end
		end

  end

end
