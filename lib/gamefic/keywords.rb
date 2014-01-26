# Arrays of keywords that can be compared for matches.

module Gamefic

	class Keywords < Array
		def initialize(statement = '')
			if statement.kind_of?(Keywords)
				self.concat statement
			else
        if statement.kind_of?(Array)
          statement = statement.join(' ')
        end
				self.concat statement.to_s.gsub(/[^a-z0-9]/i, ' ').strip.downcase.split(' ')
			end
			self.delete_if { |w|
				w.length < 2 or w == 'an' or w == 'the'
			}
			self.uniq!
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
		def to_s
			self.join(' ')
		end
	end

end
