require "singleton"
require "lib/node.rb"
require "lib/query.rb"
require "lib/director"

module Gamefic

	class Story < Root
		attr_reader :scenes, :instructions, :commands, :conclusions, :declared_scripts
		attr_accessor :story
		def commandwords
			words = Array.new
			@instructions.each { |i|
				words.push(i.syntax.split_words[0])
			}
			words.uniq
		end
		def initialize
			super
			@scenes = Hash.new
			@commands = Hash.new
			@instructions = InstructionArray.new
			@conclusions = Hash.new
			@update_procs = Array.new
			@declared_scripts = Array.new
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
				if a.specificity == b.specificity
					b.creation_order <=> a.creation_order
				else
					b.specificity <=> a.specificity
				end
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
				al = a.syntax.split.length
				bl = b.syntax.split.length
				if al == bl
					b.creation_order <=> a.creation_order
				else
					bl <=> al
				end
			}
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
		def subquery(context, *arguments)
			Subquery.new(context, arguments)
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
		def tell entities, message, refresh = false
			entities.each { |entity|
				entity.tell message, refresh
			}
		end
		# Load a script into the story. Return true on success.
		def load filename
			story = self
			File.open(filename) do |file|
				eval(file.read, nil, filename, 1)
			end
			true
		end
		# Load a script once per story. Return true on success or false if the script has already been loaded.
		def declare filename
			if @declared_scripts.include?(filename) == false
				story = self
				File.open(filename) do |file|
					eval(file.read, nil, filename, 1)
				end
				@declared_scripts.push filename
				true
			else
				false
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
		def episodes_featuring(entity)
			featured = Array.new
			@episodes.each { |episode|
				if episode.features?(entity)
					featured.push episode
				end
			}
			return featured
		end
	end

	class RootWithEpisodes < Story
		def initialize(entity)
			@children = Series.instance.children
			@commands = Series.instance.commands
			@instructions = Series.instance.instructions
			Series.instance.episodes.each { |episode|
				if episode.features?(entity)
					@children.concat episode.children
					@commands = episode.commands
					@instructions = episode.instructions
				end
			}
		end
	end

	# Episodes inherit content from the Series.
	class Episode < Story
		def initialize
			super
			Series.instance.episodes.push self
			@featuring = Array.new
			@concluded = Array.new
			Series.instance.commands.each { |key, array|
				@commands[key] = array.clone
			}
			@instructions = Series.instance.instructions.clone
			@declared_scripts = Series.instance.declared_scripts.clone
		end
		def featuring
			@featuring.clone
		end
		def features?(entity)
			@featuring.include? entity
		end
		def introduce(player)
			if Series.instance.episodes_featuring(player).length > 0
				player.tell "You're already involved in another story."
			else
				# When players join an episode, make them Featurable so they can still access entities from the Series.
				player.extend Featurable
				#player.story = self
				@featuring.push player
				super
			end
		end
		def conclude(key, player)
			super
			@concluded.push player
		end
		def update
			super
			@concluded.each { |player|
				if player.parent.root == Series.instance
					@featuring.delete player
				end
			}
			if @concluded.length > 0 and @featuring.length == 0
				Series.instance.episodes.delete self
			end
		end
	end
	
	module Featurable
		# Access entities in the Series and all episodes featuring this entity.
		def root
			RootWithEpisodes.new self
		end
		def story
			RootWithEpisodes.new self
		end
	end

end
