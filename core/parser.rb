class Parser
	@@syntaxes = Hash.new
	class Conversion
		@@creation_order = 0
		attr_reader :syntax, :result, :creation_order
		def initialize (syntax, result)
			@syntax = syntax
			@result = result
			@creation_order = @@creation_order
			@@creation_order = @@creation_order + 1
		end
		def command
			@result.split_words[0]
		end
	end
	class Statement
		attr_reader :syntax, :arguments
		def initialize (syntax, arguments)
			@syntax = syntax
			@arguments = arguments
		end
		def command
			@syntax.split_words[0]
		end
	end
	def self.commands
		@@syntaxes.keys.sort
	end
	def self.translate(syntax, result)
		syntax_words = syntax.split_words
		conversion = Conversion.new syntax, result
		cmd = syntax_words[0]
		if @@syntaxes[cmd] == nil
			@@syntaxes[cmd] = Array.new
		end
		@@syntaxes[cmd].push conversion
		@@syntaxes[cmd].sort! { |a, b|
			if b.syntax.split_words.length != a.syntax.split_words.length
				b.syntax.split_words.length <=> a.syntax.split_words.length
			else
				b.creation_order <=> a.creation_order
			end
		}
	end
	def self.parse(input)
		results = Array.new
		words = input.split_words
		conversions = @@syntaxes[words[0]]
		if (conversions == nil)
			return results
		end
		conversions.each { |conv|
			input_words = words.clone
			# Tokens are the words or word groups taken from the input.
			tokens = Hash.new
			syntax_words = conv.syntax.split_words
			while syntax_words.length > 0
				if input_words.length == 0
					# No more input. Break with an imbalance.
					break
				end
				symbol = syntax_words.shift
				if symbol[0,1] == "["
					if syntax_words.length == 0
						# Last syntax word.
						tokens[symbol] = input_words.join(' ')
						input_words.clear
						break
					elsif input_words.length == 0
						# Last input word.
						break
					else
						non_vars = syntax_words.clone.delete_if { |w|
							w[0, 1] == '['
						}
						if non_vars.length == 0
							# All remaining words in the syntax are variables. Dump everything now.
							tokens[symbol] = input_words.join(' ')
							syntax_words.clear
							input_words.clear
						else
							next_syntax_word = syntax_words.shift
							token = ''
							if syntax_words.length == 0
								break
							end
							next_input_word = input_words.shift
							while next_input_word != next_syntax_word and input_words.length > 0
								token = token + "#{next_input_word}"
								next_input_word = input_words.shift
							end
							if input_words.length == 0 and syntax_words.length > 0
								break
							else
								tokens[symbol] = token
							end
						end
					end
				else
					if input_words[0] == symbol
						input_words.shift
					else
						break
					end
				end
			end
			if input_words.length == 0 and syntax_words.length == 0
				result_words = conv.result.split_words
				result_words.shift
				arguments = Array.new
				result_words.each { |r|
					if r[0, 1] == '['
						if tokens[r] != nil
							arguments.push(tokens[r])
						end
					else
						# The result has a static word. Treat it as an argument.
						arguments.push(r)
					end
				}
				results.push(Statement.new(conv.result, arguments))
			end
		}
		return results
	end
end
