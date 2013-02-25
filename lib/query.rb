require "lib/keywords.rb"

module Gamefic

	class Query
		def initialize(context, arguments)
			if context != :family and context != :children and context != :siblings and context != :parent and context != :self and context != :root and context != :string
				raise "Query context must be :family, :children, :siblings, :parent, :self, :root, or :string"
			end
			if context == :string and arguments.length > 0
				raise "Query with :string context cannot take additional arguments."
			end
			@context = context
			@arguments = arguments
		end
		def execute(subject, description)
			case context
				when :self
					array = [subject]
				when :parent
					array = [subject.parent]
				when :root
					array = subject.root.flatten
				when :children
					array = subject.children
				when :siblings
					array = subject.parent.children
				when :family
					array = subject.children + subject.parent.children
				when :string
					return Matches.new([description], description, '')
				else
					raise "Unrecognized: #{context}"
			end
			@arguments.each { |arg|
				if arg.kind_of?(Class) or arg.kind_of?(Module)
					array.delete_if { |entity| entity.kind_of?(arg) == false }
				else
					if array.include?(arg)
						array = Array.new
						array.push(arg)
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
		def specificity
			if @specificity == nil
				@specificity = 0
				case @context
					when :children
						@specificity += 50
					when :siblings
						@specificity += 40
					when :family
						@specificity += 30
					when :parent
						@specificity += 20
					when :self
						@specificity += 10
					when :string
						@specificity = 1
						return @specificity
				end
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
					magnitude = magnitude * 10
				}
			end
			@specificity
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

	class Subquery < Query
	
	end
	
end
