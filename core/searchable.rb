require "core/keywords.rb"

module Gamefic

	class Query
		def initialize(context, *arguments)
			if context != :self and context != :parent and context != :root
				raise "Query context must be :self, :parent, or :root."
			end
			@context = context
			@arguments = arguments
		end
		def execute(subject, description)
			array = @subject.send(context).children
			@arguments.each { |arg|
				if arg.king_of?(Class)
					array.delete_if { |entity| entity.kind_of?(arg) == false }
				else
					if array.include?(arg)
						array = Array.new.push(arg)
					else
						array.empty
					end
				end
			}
			array = match(description, array)
			return array
		end
		private
		def match(description, array)
			result = array.new
			mostMatches = 0
			words = Keywords.new description
			if words.length > 0
				self.each {|entity|
					matches = words.found_in entity.keywords
					if matches > 0 and matches - mostMatches >= 0
						if matches - mostMatches > 0.5 and result.length > 0
							result = self.class.new
						end
						mostMatches = matches
						result.push entity
					end
				}
			end
			return result
		end
	end

end
