require "core/keywords.rb"

module Gamefic

	class Query
		def initialize(context, arguments)
			if context != :self and context != :parent and context != :root
				raise "Query context must be :self, :parent, or :root."
			end
			@context = context
			@arguments = arguments
		end
		def execute(subject, description)
			array = subject.send(context).children
			puts "Starting with #{array.length}"
			@arguments.each { |arg|
				puts arg.class
				if arg.kind_of?(Class)
					puts "Gotta be #{arg}"
					array.delete_if { |entity| entity.kind_of?(arg) == false }
				else
					if array.include?(arg)
						array = Array.new.push(arg)
					else
						array.clear
					end
				end
			}
			return Query.match(description, array)
		end
		def context
			@context
		end
		def self.match(description, array)
			puts "Checking #{array.length}"
			keywords = description.split_words
			results = array
			used = Array.new
			if results.length > 0
				previous_match = false
				while keywords.length > 0
					used.push keywords.shift
					new_results = results.matching(used)
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
			puts "#{results.length} matched #{description}"
			return Matches.new(results, used.join(' '), keywords.join(' '))
			#Matches.new(results, used.join(' '), keywords.join(' '))
			#result = array.new
			#mostMatches = 0
			#words = Keywords.new description
			#if words.length > 0
			#	self.each {|entity|
			#		matches = words.found_in entity.keywords
			#		if matches > 0 and matches - mostMatches >= 0
			#			if matches - mostMatches > 0.5 and result.length > 0
			#				result = self.class.new
			#			end
			#			mostMatches = matches
			#			result.push entity
			#		end
			#	}
			#end
			#return result
		end
		class Matches
			attr_reader :objects, :matching_text, :remainder
			def initialize(objects, matching_text, remainder)
				@objects = objects
				@matching_text = matching_text
				@remainder = remainder
			end
		end
	end

end
