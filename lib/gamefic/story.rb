require_relative "./plot"

module Gamefic

	class Story < Plot
		def post_initialize
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
	
	class StoryWithSubplots < Plot
		def initialize(story, entity)
			@story = story
			@entities = @story.entities
			@commands = @story.commands
			@syntaxes = @story.syntaxes
			story.subplots_featuring(entity).each { |sub|
				@entities.concat(sub.entities)
				# TODO: Commands and syntaxes should be concatenated and sorted
				@commands = sub.commands
				@syntaxes = sub.syntaxes
			}
		end
	end

	class Subplot < Plot
		def initialize(story, args = {})
			@story = story
			super()
			story.subplots.push self
			@featuring = Array.new
			@concluded = Array.new
			# TODO: Maybe don't clone commands and stuff here.
			# Do it in StoryWithSubplots instead.
			@story.commands.each { |key, array|
				@commands[key] = array.clone
			}
			@syntaxes = story.syntaxes.clone
			@declared_scripts = story.declared_scripts.clone
			args.each { |key, value|
				self.send("#{key}=", value)
			}
			post_initialize
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
			if player.kind_of?(Featurable) == false
				player.extend Featurable
			end
			@featuring.push player
			super
		end
		def conclude(player, key = nil)
			super
			@concluded.push player
			@concluded.each { |player|
				if player.parent == nil or player.parent.plot != self
					@featuring.delete player
				end
			}
			if @concluded.length > 0 and @featuring.length == 0
				story.subplots.delete self
			end
		end
	end
	
	module Featurable
		# Access content in the Story and all Subplots featuring this entity.
		def plot
			story = super
			if story.subplots_featuring(self).length == 0
				return story
			end
			StoryWithSubplots.new story, self
		end
	end

end
