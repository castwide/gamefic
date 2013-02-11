class Parser
	@@syntaxes = Hash.new
	class Conversion
		attr_reader :syntax, :result, :action
		def initialize (syntax, result)
			@syntax = syntax
			@result = result
			def actions
				Action.actions_for(@result.split_words[0])
			end
		end
	end
	class Result
		attr_reader :action, :arguments
		def initialize (action, arguments)
			@action = action
			@arguments = arguments
		end
	end
	def self.translate(syntax, result)
		actions = Action.actions_for(result.split_words[0])
		if actions == nil
			raise "Could not find an Action that matches '#{result}'"
		end
		syntax_words = syntax.split_words
		conversion = Conversion.new syntax, result
		cmd = syntax_words[0]
		if @@syntaxes[cmd] == nil
			@@syntaxes[cmd] = Array.new
		end
		@@syntaxes[cmd].push conversion
		@@syntaxes[cmd].sort! { |a, b|
			b.syntax.split_words.length <=> a.syntax.split_words.length
		}
	end
	def self.parse(input)
		results = Array.new
		words = input.split_words
		conversions = @@syntaxes[words[0]]
		if (conversions == nil)
			return results
		end
		# Tokens are the words or word groups taken from the input.
		conversions.each { |conv|
			conv.actions.each { |action|
				input_words = words.clone
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
						if r[0, 1] == '[' and tokens[r] != nil
							arguments.push(tokens[r])
						#else
						#	arguments.push(r)
						end
					}
					results.push(Result.new(action, arguments))
				end
			}
		}
		return results
	end
end
