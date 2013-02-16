require "singleton"
require "core/node.rb"
require "core/script.rb"
require "core/query.rb"

module Gamefic

	class Story < Root
		include Scriptable
		attr_reader :scenes, :instructions, :commands, :conclusions
		def initialize
			super
			@scenes = Hash.new
			@commands = Hash.new
			@instructions = InstructionArray.new
			@conclusions = Hash.new
			@hashed_entities = Hash.new
			@script_commands =	{
				:action => Proc.new { |command, *arguments|
					proc = arguments.pop
					action = Action.new(command, arguments, proc)
					if (@commands[command] == nil)
						@commands[command] = Array.new
					end
					@commands[command].push action
					user_friendly = command.to_s.gsub(/_/, ' ')
					syntax = ''
					used_names = Array.new
					action.contexts.each { |c|
						num = 1
						new_name = "[#{c.description}]"
						while used_names.include? new_name
							num = num + 1
							new_name = "[#{c.description}#{num}]"
						end
						used_names.push new_name
						syntax = syntax + " #{new_name}"
					}
					@instructions.push Parser::Instruction.new(user_friendly + syntax, command, syntax)
				},
				:instruct => Proc.new { |syntax, command, statement|
					@instructions.push Parser::Instruction.new(syntax, command, statement)
				},
				:prop => Proc.new { |key, klass|
					obj = klass.new
					obj.parent = self
					obj.name = key.to_s.gsub(/_/, ' ')
					@hashed_entities[key] = obj
					@script_commands[key] = lambda { obj }
				},
				:introduction => Proc.new { |*arguments|
					proc = arguments.pop.pop
					@introduction = proc
				},
				:conclusion => Proc.new  { |key, *arguments|
					proc = arguments.pop
					@conclusions[key] = proc
				},
				:scene => Proc.new { |key, *arguments|
					proc = arguments.pop
					@scenes[key] = proc
				}
			}
		end
		def action(command, *arguments, &proc)
			action = Action.new(command, arguments, proc)
			if (@commands[command] == nil)
				@commands[command] = Array.new
			end
			@commands[command].push action
			user_friendly = command.to_s.gsub(/_/, ' ')
			syntax = ''
			used_names = Array.new
			action.contexts.each { |c|
				num = 1
				new_name = "[#{c.class}]"
				while used_names.include? new_name
					num = num + 1
					new_name = "[#{c.class}#{num}]"
				end
				used_names.push new_name
				syntax = syntax + " #{new_name}"
			}
			@instructions.push Parser::Instruction.new(user_friendly + syntax, command, syntax)
		end
		def instruct(syntax, command, statement)
			@instructions.push Parser::Instruction.new(syntax, command, statement)
		end
		def prop(key, klass)
			obj = klass.new
			obj.parent = self
			obj.name = key.to_s.gsub(/_/, ' ')
			@hashed_entities[key] = obj
			@script_commands[key] = lambda { obj }
		end
		def introduction (&proc)
			@introduction = proc
		end
		def conclusion(key, &proc)
			@conclusions[key] = proc
		end
		def scene(key, &proc)
			@scenes[key] = proc
		end
		def script_commands
			@script_commands
		end
		def introduce(player)
			if @introduction != nil
				@introduction.call(player)
			end
		end
		def conclude(key)
			if @conclusions[key]
				@conclusions[key].call
			end
		end
		def cue scene
			@scenes[scene].call
		end
		def query(context, *arguments)
			Query.new(context, arguments)
		end
		def method_missing(symbol, *arguments)
			@hashed_entities[symbol] ||= super
		end
	end

	class Series < Story
		include Singleton
		def initialize
			super
			@episodes = Array.new
		end
		def root(entity = nil)
			result = super()
			if (entity != nil)
				result = result.clone
				@episodes.each { |episode|
					if episode.features(entity)
						result.concat_children episode.children
					end
				}
			end
		end
		#protected
		def episodes
			@episodes
		end
	end

	class Episode < Story
		def initialize
			super
			Series.instance.episodes.push self
			@featuring = Array.new
		end
		def featuring
			@featuring.clone
		end
		def introduce(player)
			player.extend Featurable
		end
		def root(entity = nil)
			result = super()
			if (entity != nil)
				result = result.clone
				result.concat_children Series.instance.children
			end
			return result
		end
	end

	module Featurable
		def root
			result = super
			result.root(self)
		end
	end

end
