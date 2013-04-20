require "singleton"
require "gamefic/plot"

module Gamefic

	class Story < Plot
		include Singleton
		def initialize
			super
			@subplots = Array.new
		end
		def subplots
			@subplots
		end
		def subplots_featuring(entity)
			featured = Array.new
			@subplots.each { |subplot|
				if subplot.features?(entity)
					featured.push subplot
				end
			}
			return featured
		end
	end
	$story = Story.instance  # Just an alias
	
	class StoryWithSubplots < Plot
		def initialize(entity)
			@entities = Story.instance.entities
			@commands = Story.instance.commands
			@syntaxes = Story.instance.syntaxes
			Story.instance.subplots.each { |sub|
				if sub.features?(entity)
					@entities.concat sub.entities
					@commands = sub.commands
					@syntaxes = sub.syntaxes
				end
			}
		end
	end

	class Subplot < Plot
		@@current_stack = Array.new
		def initialize(args = {})
			@@current_stack.push self
			super()
			Story.instance.subplots.push self
			@featuring = Array.new
			@concluded = Array.new
			Story.instance.commands.each { |key, array|
				@commands[key] = array.clone
			}
			@syntaxes = Story.instance.syntaxes.clone
			@declared_scripts = Story.instance.declared_scripts.clone
			args.each { |key, value|
				self.send("#{key}=", value)
			}
			post_initialize
			@@current_stack.pop
		end
		def post_initialize
			# Nothing to do unless inherited
		end
		def featuring
			@featuring.clone
		end
		def features?(entity)
			@featuring.include? entity
		end
		def introduce(player)
			if Story.instance.subplots_featuring(player).length > 0
				player.tell "You're already involved in another subplot."
			else
				if player.kind_of?(Featurable) == false
					player.extend Featurable
				end
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
				Series.instance.subplots.delete self
			end
		end
		def load_script(filename)
			@@current_stack.push self
			super
			@@current_stack.pop self
		end
		def Subplot.current
			@@current_stack.last || Story.instance
		end
	end
	
	module Featurable
		# Access content in the Story and all Subplots featuring this entity.
		def story
			StoryWithSubplots.new self
		end
	end

end
