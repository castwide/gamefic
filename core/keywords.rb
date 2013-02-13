# Arrays of keywords that can be compared for matches.

module Gamefic

	class Keywords < Array
		def Keywords.from(statement)
			result = Keywords.new
			if statement.kind_of?(Array)
				result.concat statement
			else
				result = Keywords.new.concat statement.to_s.strip.downcase.split
			end
			result.delete_if { |w|
				w.length < 2 or w == 'an' or w == 'the'
			}
			result.uniq!
			return result
		end
		def found_in(other)
			matches = 0.0
			self.each { |my_word|
				if (other.include?(my_word))
					matches = matches + 1.0
				else
					other.each { |other_word|
						if my_word.length < other_word.length
							if other_word[0, my_word.length] == my_word
								matches = matches + (my_word.length.to_f / other_word.length.to_f)
							end
						end
					}
				end
			}
			return matches
		end
	end

end
