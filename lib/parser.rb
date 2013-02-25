module Gamefic

	class InstructionArray < Array
		def parse(input)
			results = Array.new
			words = input.split_words
			self.each { |conv|
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
									token = token + " #{next_input_word}"
									next_input_word = input_words.shift
								end
								if input_words.length == 0 and syntax_words.length > 0
									break
								else
									tokens[symbol] = token.strip
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
					result_words = conv.statement.split_words
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
					results.push(Parser::Statement.new(conv.statement, conv.command, arguments))
				end
			}
			return results
		end
	end
	
	class Parser
		class Instruction
			@@creation_order = 0
			attr_reader :syntax, :command, :statement, :creation_order
			def initialize (syntax, command, statement)
				if (command.kind_of?(Symbol) == false)
					raise "Instruction command must be a Symbol"
				end
				@syntax = syntax
				@command = command
				@statement = statement
				@creation_order = @@creation_order
				@@creation_order = @@creation_order + 1
			end
		end
	end
	
	class Parser
		class Statement
			attr_reader :syntax, :command, :arguments
			def initialize (syntax, command, arguments)
				@syntax = syntax
				@command = command
				@arguments = arguments
			end
		end
		def self.instruct(syntax, command, statement)
			Instruction.new(syntax, command, statement)
		end
	end

end
