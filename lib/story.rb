require "singleton"
require "lib/node.rb"
require "lib/script.rb"
require "lib/query.rb"
require "lib/director"

module Gamefic

	class Story < Root
		include Scriptable
		attr_reader :scenes, :instructions, :commands, :conclusions
		def initialize
			super
			@@current = self
			@scenes = Hash.new
			@commands = Hash.new
			@instructions = InstructionArray.new
			@conclusions = Hash.new
			@hashed_entities = Hash.new
			@update_procs = Array.new
		end
		def on_update(&block)
			@update_procs.push block
		end
		def action(command, *arguments, &proc)
			action = Action.new(command, arguments, proc)
			if (@commands[command] == nil)
				@commands[command] = Array.new
			end
			@commands[command].push action
			@commands[command].sort! { |a, b|
				b.specificity <=> a.specificity
			}
			user_friendly = command.to_s.gsub(/_/, ' ')
			syntax = ''
			used_names = Array.new
			action.contexts.each { |c|
				num = 1
				new_name = "[var]"
				while used_names.include? new_name
					num = num + 1
					new_name = "[var#{num}]"
				end
				used_names.push new_name
				syntax = syntax + " #{new_name}"
			}
			instruct user_friendly + syntax, command, syntax
		end
		def instruct(syntax, command, statement)
			@instructions.push Parser::Instruction.new(syntax, command, statement)
			@instructions.sort! { |a, b|
				b.syntax.split.length <=> a.syntax.split.length
			}
		end
		def prop(key, klass, args = {})
			obj = klass.new(self)
			obj.parent = self
			obj.name = key.to_s.gsub(/_/, ' ')
			args.each { |key, value|
				obj.send("#{key}=", value)
			}
			@hashed_entities[key] = obj
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
			player.story = self
			if @introduction != nil
				@introduction.call(player)
			end
		end
		def conclude(key, player)
			if @conclusions[key]
				@conclusions[key].call(player)
			end
		end
		def cue scene
			@scenes[scene].call
		end
		def query(context, *arguments)
			Query.new(context, arguments)
		end
		def passthru
			Director::Delegate.passthru
		end
		def update
			@update_procs.each { |p|
				p.call
			}
			@children.flatten.each { |e|
				recursive_update e
			}
		end
		def method_missing(symbol, *arguments)
			if @hashed_entities.has_key?(symbol)
				@hashed_entities[symbol]
			else
				raise "Undeclared entity '#{symbol}'"
			end
		end
		private
		def recursive_update(entity)
			entity.update
			entity.children.each { |e|
				recursive_update e
			}
		end
	end

	class Series < Story
		include Singleton
		def initialize
			super
			@episodes = Array.new
		end
		def update
			super
			@episodes.each { |episode|
				episode.update
			}
		end
		def episodes
			@episodes
		end
		def root_with_episodes(entity)
		
		end
		class RootWithEpisodes < Story
			def initialize(entity)
				@children = Series.instance.children
				@commands = Series.instance.commands
				@instructions = Series.instance.instructions
				Series.instance.episodes.each { |episode|
					if episode.features?(entity)
						@children.concat episode.children
					end
				}
			end
		end
	end

	class Episode < Story
		def initialize
			super
			Series.instance.episodes.push self
			@featuring = Array.new
			@concluded = Array.new
			@commands = Series.instance.commands.clone
			@instructions = Series.instance.instructions.clone
		end
		def featuring
			@featuring.clone
		end
		def features?(entity)
			@featuring.include? entity
		end
		def introduce(player)
			player.extend Featurable
			@featuring.push player
			super
		end
		def conclude(key, player)
			super
			#@featuring.delete player
			@concluded.push player
			#if @featuring.length == 0
			#	Series.instance.episodes.delete self
			#end
		end
		def update
			super
			@concluded.each { |player|
				if player.parent.root == Series.instance
					puts "Removing concluded player"
					@featuring.delete player
				end
			}
			if @concluded.length > 0 and @featuring.length == 0
				puts "Deleting episode"
				Series.instance.episodes.delete self
			end
		end
	end
	
	module Featurable
		def root
			Series::RootWithEpisodes.new self
		end
	end

end
