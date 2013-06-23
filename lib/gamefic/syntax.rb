module Gamefic

	class Syntax
		attr_reader :template, :command, :arguments, :creation_order
		def initialize(story, *arguments)
			if arguments.length < 2
				raise "Syntax.new requires at least two arguments (template and command)"
			end
			@template = arguments.shift
			@command = arguments.shift
			@arguments = arguments
			@creation_order = story.syntaxes.length + 1
			story.send :add_syntax, self
			@story = story
		end
		def self.match(input, syntaxes)
			# Given the input, return all the syntaxes that potentially match it.
			matches = Array.new
			words = input.split_words
			syntaxes.each { |syntax|
				input_words = words.clone
				tokens = Hash.new
				syntax_words = syntax.template.split_words
				while syntax_words.length > 0
					if input_words.length == 0
						# No more input. Break with an imbalance.
						break
					end
					symbol = syntax_words.shift
					if symbol[0, 1] == ":"
						if syntax_words.length == 0
							# Last syntax word.
							tokens[symbol[1..-1].to_sym] = input_words.join(' ')
							input_words.clear
							break
						elsif input_words.length == 0
							# Last input word.
							break
						else
							non_vars = syntax_words.clone.delete_if { |w|
								w[0, 1] == ':'
							}
							if non_vars.length == 0
								# All remaining words in the syntax are variables. Dump everything now.
								tokens[symbol[1..-1].to_sym] = input_words.join(' ')
								syntax_words.clear
								input_words.clear
							else
								next_syntax_word = syntax_words.shift
								token = ''
								if syntax_words.length == 0
									last_input_word = input_words.pop
									if last_input_word == next_syntax_word
										tokens[symbol[1..-1].to_sym] = input_words.join(' ')
										input_words.clear
									end
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
									tokens[symbol[1..-1].to_sym] = token.strip
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
					arguments = Array.new
					syntax.arguments.each { |a|
						if a.kind_of?(Symbol)
							if tokens[a] != nil and tokens[a] != ''
								arguments.push(tokens[a])
							end						
						else
							if a != nil and a != ''
								arguments.push(a)
							end						
						end
					}
					if syntax.arguments.length == arguments.length
						matches.push CommandHandler.new(syntax.command, arguments)
					end
				end
			}
			matches.uniq!    # TODO: Is this necessary?
			return matches
		end
	end
	
	class CommandHandler
		attr_reader :command, :arguments
		def initialize command, arguments
			@command = command
			@arguments = arguments
		end
	end

end
