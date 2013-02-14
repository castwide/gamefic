require "singleton"
require "delegate"

module Gamefic
	module Stage
		attr_reader :entities, :actions, :instructions
		def theater
			Theater.instance
		end
		def hashed_entities
			@hashed_entities
		end
		def entities
			@entities.clone
		end
		def commands
			@commands.clone
		end
		def instructions
			@instructions.clone
		end
		def entity(key)
			hashed_entities[key]
		end
		def self.get_binding(story)
			return binding
		end
		def destroy(entity)
			# TODO: Handle orphanange or destruction of children
			# TODO: This method probably belongs elsewhere
			# TODO: Hell, do we even need an explicit destruction method?
			# Just orphan the damn thing, right? Except for players
			# who leave the game...
			@entities.delete(entity)
		end
		private
		def prepare_stage
			@entities = EntityArray.new
			@hashed_entities = Hash.new
			@commands = Hash.new
			@instructions = InstructionArray.new
			@action_number = 0
			@instruction_number = 0
		end
	end
	module Direction
		include Stage
		STRING = Context.new("text", [String])
		INVENTORY = Context.new("my_thing", [[:self, :children]])
		PROXIMATE = Context.new("thing_in_room", [[:parent, :children]])
		NEIGHBOR = PROXIMATE
		NEARBY = PROXIMATE
		PARENT = Context.new("place", [:parent])
		PLACE = PARENT
		ENVIRONMENT = Context.new("thing", [[:self, :children], [:parent, :children]])
		NEARBY_OR_INVENTORY = ENVIRONMENT
		ANYWHERE = Context.new("thing_anywhere", [Object])
		ALL = ANYWHERE
		def action command, *contexts, &block
			action = Action.new(command, contexts, block)
			action.creation_order = @action_number
			@action_number = @action_number + 1
			if @commands[command] == nil
				@commands[command] = Array.new
			end
			@commands[command].push action
			@commands[command].sort! { |a,b|
				if b.specificity == a.specificity
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
				new_name = "[#{c.description}]"
				while used_names.include? new_name
					num = num + 1
					new_name = "[#{c.description}#{num}]"
				end
				used_names.push new_name
				syntax = syntax + " #{new_name}"
			}
			instruct user_friendly + syntax, command, syntax
		end
		def instruct syntax, action, statement
			instruction = Parser.instruct(syntax, action, statement)
			instruction.creation_order = @instruction_number
			@instruction_number = @instruction_number + 1
			@instructions.push instruction
			@instructions.sort! { |a, b|
				if b.syntax.split_words.length != a.syntax.split_words.length
					b.syntax.split_words.length <=> a.syntax.split_words.length
				else
					b.creation_order <=> a.creation_order
				end
			}
		end	
		def prop key, klass, &block
			obj = klass.new self
			if key == nil
				key = obj.object_id.to_s.to_sym
			end
			@hashed_entities[key] = obj
			if (block != nil)
				block.call obj
			end
			if obj.name.to_s == ''
				obj.name = key.to_s.gsub(/_/, ' ')
			end
			@entities.push obj
			return obj
		end
		def track entity
			@entities.push entity
		end
		def get_binding(scaffold)
			return binding
		end
		def scaffold(filename)
			File.open(filename) do |file|
				eval(file.read, get_binding(self), filename, 1)
			end
		end
		def method_missing(symbol, *arguments)
			if arguments.length == 0
				if entity(symbol) != nil
					return entity(symbol)
				end
			end
			raise "Unrecognized method or entity \"#{symbol}\""
		end
	end
	module Narrative
		include Direction
		attr_reader :introduction, :conclusions, :scenes
		def introduction &block
			@introduction = block
		end
		def conclusion name, &block
			@conclusions[name] = block
		end
		def scene name, &block
			@scenes[name] = block
		end
		def get_binding(script)
			return binding
		end
		def script(filename)
			File.open(filename) do |file|
				eval(file.read, get_binding(self), filename, 1)
			end		
		end
		private
		def prepare_narrative
			prepare_stage
			@introduction = nil
			@conclusions = Hash.new
			@scenes = Hash.new
		end
	end
	class Story
		include Narrative
		def initialize
			@player = nil
			prepare_narrative
		end
		module Blocking
			def entities
				@entities.concat theater.entities
			end
			def hashed_entities
				theater.hashed_entities.clone.update @hashed_entities
			end
			def commands
				commands = @commands
				theater.commands.each { |key, acts|
					if commands[key] == nil
						commands[key] = Array.new
					end
					commands[key].concat acts
				}
				return commands
			end
			def instructions
				@instructions.clone.concat theater.instructions
			end
			def introduction
				@introduction
			end
			def conclusions
				@conclusions
			end
			def scenes
				@scenes
			end
			def player
				@player
			end
			def introduce player
				@player = player
				@introduction.call
				@player.cast(self)
			end
			def conclude ending
				@conclusions[ending].call
			end
			def cue scene
				@scenes[scene].call
			end
			def passthru
				Director::Delegate.passthru
			end
		end
	end
	class Performance
		def initialize(story)
			@story = story
			@story.extend Story::Blocking
		end
		def introduce player
			@story.introduce player
			game = Game.new
			game.run player
		end
	end
	class Theater
		include Singleton
		include Direction
		def initialize
			prepare_stage
		end
	end
end
