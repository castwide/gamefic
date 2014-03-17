module Gamefic

	class Director
		def self.dispatch(actor, command)
			command.strip!
      verbs = actor.plot.commandwords
      first = command.split(' ')[0].downcase
      if verbs.include?(first) == false
        possibles = []
        verbs.each { |v|
          if v.start_with?(first)
            possibles.push v
          end
        }
        if possibles.length == 1
          command = possibles[0] + command[first.length..-1]
        else
          if possibles.length > 1
            actor.tell "'#{first.cap_first}' is ambiguous."
          else
            actor.tell "I don't understand '#{first}' as a command."
          end
          return
        end
      end
			handlers = Syntax.match(command, actor.plot.syntaxes)
			options = Array.new
			handlers.each { |handler|
				actions = actor.plot.commands[handler.command]
				if actions != nil
					actions.each { |action|
						orders = bind_contexts_in_result(actor, handler, action)
						orders.each { |order|
							args = Array.new
							args.push actor
							order.arguments.each { |a|
								if a.length > 1
									longnames = Array.new
									a.each { |b|
										longnames.push b.longname
									}
									actor.tell "I don't know which you mean: #{longnames.join(', ')}"
									return
								end
								args.push a[0]
							}
							options.push [order.action.proc, args]
						}
					}
				end
			}
			options.push([
				Proc.new { |actor|
          first = command.split(' ')[0]
          if actor.plot.commandwords.include?(first)
            actor.tell "I know the verb '#{first}' but couldn't understand the rest of your sentence."
          else
            actor.tell "I don't understand '#{first}' as a command."
          end
				}, [actor], -1
			])
			del = Delegate.new(options)
			del.execute
		end
		private
		def self.bind_contexts_in_result(actor, handler, action)
			objects = Array.new
			valid = true
			prepared = Array.new
			arguments = handler.arguments.clone
			action.queries.each { |context|
				arg = arguments.shift
				if arg == nil or arg == ''
					valid = false
					next
				end
				if context == String
					prepared.push [arg]
				elsif context.kind_of?(Query)
					if context.kind_of?(Subquery)
						last = prepared.last
						if last == nil or last.length > 1
							valid = false
							next
						end
            if arg == 'it' and actor.object_of_pronoun != nil
              result = context.execute(last[0], "#{actor.object_of_pronoun.longname}")
            else
              result = context.execute(last[0], arg)
            end
					else
            if arg == 'it' and actor.object_of_pronoun != nil
              result = context.execute(actor, "#{actor.object_of_pronoun.longname}")
            else
              result = context.execute(actor, arg)
            end
					end
					if result.objects.length == 0
						valid = false
						next
					else
						prepared.push result.objects
						if result.remainder
							arguments.push result.remainder
						end
					end
				else
					# TODO: Better message
					raise "Invalid object"
				end
			}
			if valid == true
				prepared.each { |p|
					p.uniq!
				}
				objects.push Order.new(action, prepared)
			end
			return objects
		end
	end
	
	class Director
		class Delegate
			@@delegation_stack = Array.new
			def initialize(options)
				@options = options
			end
			def execute
				@@delegation_stack.push @options
				if @options.length > 0
					opt = @options.shift
					if opt[1].length == 1
						opt[0].call(opt[1][0])
					else
            if opt[1].length == 2 and opt[1][1].kind_of?(Entity)
              opt[1][0].object_of_pronoun = opt[1][1]
            else
              opt[1][0].object_of_pronoun = nil
            end
						opt[0].call(opt[1])
					end
				end
				@@delegation_stack.pop
			end
			def self.passthru
				if @@delegation_stack.last != nil
					if @@delegation_stack.last.length > 0
						opt = @@delegation_stack.last.shift
						if opt[1].length == 1
							opt[0].call(opt[1][0])
						else
							opt[0].call(opt[1])
						end
					end
				end
			end
		end
		class Order
			attr_reader :action, :arguments
			def initialize(action, arguments)
				@action = action
				@arguments = arguments
			end
		end
	end

	def self.passthru
		Director::Delegate.passthru
	end

end
