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
            #  item = item.class
            #end
            #if item.kind_of?(Class)
            #  s = item
            #  while s != nil
            #    @specificity += (magnitude * 10)
            #    s = s.superclass
            #  end
            else
              @specificity += magnitude
            end
            #magnitude = magnitude * 10
          }
        end
        @specificity
      end
    end
    
    class Text < Base
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
        subject.children + subject.parent.children + [subject.parent]
      end
    end
    
    def self.match(description, array)
			array.each {|e|
				if e.uid == description
					return Matches.new([e], description, '')
				end
			}
			keywords = description.split_words
			results = array
			used = Array.new
			if results.length > 0
				previous_match = false
				while keywords.length > 0
					used.push keywords.shift
					new_results = Array.new
					mostMatches = 0.0
					results.each { |r|
						words = Keywords.new(used.join(' '))
						if words.length > 0
							matches = words.found_in r.keywords
							if matches >= mostMatches and matches > 0
								if matches - mostMatches > 0.5
									new_results = Array.new
								end
								new_results.push r
								mostMatches = matches
							end
						end
					}
					if new_results.length == 0
						if previous_match == true
							keywords.unshift used.pop
							if used.length == 0
								results = new_results
							end
							break
						end
					else
						previous_match = true
						results = new_results
						if results.length == 1
							break
						end
					end
				end
				if previous_match == false
					# Scrolled through every word and not a single thing matched
					results = Array.new
				end
			end
			return Matches.new(results, used.join(' '), keywords.join(' '))
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
