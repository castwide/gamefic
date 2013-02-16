# Contexts tell actions where they should look for arguments.

module Gamefic

	class Context
		class Matches
			attr_reader :objects, :matching_text, :remainder
			def initialize(objects, matching_text, remainder)
				@objects = objects
				@matching_text = matching_text
				@remainder = remainder
			end
		end
		attr_reader :description, :arguments
		def initialize(description, arguments)
			@description = description
			@arguments = arguments
		end
		def match(subject, keywords)
			results = Searchable::SearchArray.new
			if keywords == nil
				return Response.new(results, '')
			end
			@arguments.each { |arg|
				if arg == String
					return Matches.new([keywords], keywords, '')
				elsif arg == Object
					results = subject.root.children
				elsif arg.class == Class or arg.class == Module
					results = results.that_are(arg)
				elsif arg.kind_of? Symbol
					if (arg == :parent)
						results = Searchable::SearchArray.new
						results.push subject.parent
					else
						if subject.respond_to? arg
							results.concat(subject.method(arg).call)
						else
							raise "Bad symbol"
						end
					end
				elsif arg.kind_of? Array
					current = subject
					arg.each { |sub_arg|
						if sub_arg == :self
							current = subject
						elsif current.respond_to? sub_arg
							current = current.method(sub_arg).call
						else
							raise "Bad symbol"
						end
					}
					results.concat(current)
				elsif arg.kind_of?(Entity)
					results = results.that_are(arg)
				else
					raise "I don't know what #{arg} is."
				end
			}
			keywords = keywords.split_words
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
					results = Searchable::SearchArray.new
				end
			end
			Matches.new(results, used.join(' '), keywords.join(' '))
		end
		def reduce(args)
			extended = Context.new(@description, @arguments.clone)
			extended.arguments.push(args)
			return extended
		end
		def specificity
			if @specificity == nil
				@specificity = 0
				flat = arguments.flatten.delete_if { |c| c == String }
				flat.each { |item|
					if item.kind_of?(Symbol)
						@specificity += 1
					elsif item != String and item.kind_of?(Class)
						s = item
						while s != nil
							@specificity += 1
							s = s.superclass
						end
					end
				}
			end
			@specificity
		end
	end

end
