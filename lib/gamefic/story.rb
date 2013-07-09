require "gamefic/plot"

module Gamefic

	class Story < Plot
		def post_initialize
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
    def update
      super
      @subplots.each { |subplot|
        subplot.update
      }
    end
		private
		def add_entity(entity)
			super
			invalidate_all
		end
		def rem_entity(entity)
			super
			invalidate_all
		end
		def add_action(action)
			super
			invalidate_all
		end
		def add_syntax(syntax)
			super
			invalidate_all
		end
		def invalidate_all
			#entities.that_are(Featurable).each do |e|
			#	StoryWithSubplots.invalidate_for self, e
			#end
      StoryWithSubplots.invalidate_for self
		end
	end
	
	class StoryWithSubplots < Plot
		@@entity_hash = Hash.new
    def initialize(plots)
      super()
      @story = plots.shift
      @entities = @story.entities
			@story.commands.each { |k, v|
        @commands[k] = v.clone
      }
			@syntaxes = @story.syntaxes.clone
      plots.each { |sub|
        @entities.concat(sub.entities)
        sub.commands.each { |key, array|
          array.each { |a|
            add_action a
          }
        }
        sub.syntaxes.each { |s|
          add_syntax s
        }
      }
      @@entity_hash[[@story] + plots] = self
    end
		def old_initialize(story, entity)
      super()
			@story = story
			@entities = @story.entities
			@story.commands.each { |k, v|
        @commands[k] = v.clone
      }
			@syntaxes = @story.syntaxes.clone
      if entity != nil
        @story.subplots_featuring(entity).each { |sub|
          @entities.concat(sub.entities)
          sub.commands.each { |key, array|
            array.each { |a|
              add_action a
            }
          }
          sub.syntaxes.each { |s|
            add_syntax s
          }
        }
        @@entity_hash[StoryWithSubplots.cache_key_for(story, entity)] = self
      end
		end
		def self.for(story, entity)
      plots = [story] + story.subplots_featuring(entity)
      cached = @@entity_hash[plots]
      if cached != nil
        return cached
      else
        self.new plots
      end
		end
		def self.invalidate_for(story)
      @@entity_hash.each { |k, s|
        if k.include?(story) == true
          @@entity_hash.delete k
        end
      }
		end
    def self.cached_for?(story, entity)
      #return (@@entity_hash[self.cache_key_for(story, entity)] != nil)
      return (@@entity_hash[[story] + story.subplots_featuring(entity)] != nil)
    end
    #def self.cache_key_for(story, entity)
    #  key = Array.new
    #  ([story] + story.subplots_featuring(entity)).each { |s|
    #    key.push s.object_id
    #  }
    #  return key
    #end
    def self.join(plots)
      cached = @@entity_hash[plots]
      if cached != nil
        return cached
      else
        sws = self.new plots
        @@entity_hash[plots] = sws
      end
    end
	end

	class Subplot < Plot
    attr_reader :story
		def initialize(story, args = {})
			@story = story
			super()
			story.subplots.push self
			@featuring = Array.new
			@concluded = Array.new
			@declared_scripts = story.declared_scripts.clone
			args.each { |key, value|
				self.send("#{key}=", value)
			}
		end
		def post_initialize
			# Nothing to do unless inherited
		end
		def featuring
			@featuring.clone
		end
		def features?(entity)
			@featuring.include?(entity)
		end
		def introduce(player)
			if player.kind_of?(Featurable) == false
				player.extend Featurable
			end
      StoryWithSubplots.invalidate_for self
			@featuring.push player
			super
		end
		def conclude(player, key = nil)
			super
			@concluded.push player
      @featuring.delete player
			StoryWithSubplots.invalidate_for self
			if @concluded.length > 0 and @featuring.length == 0
				story.subplots.delete self
			end
		end
		private
		def add_entity(entity)
      if entity.kind_of?(Featurable) == false and entity.kind_of?(Subplotted) == false
        entity.extend Subplotted
      end
			super
			invalidate_all
		end
		def rem_entity(entity)
			super
			invalidate_all
		end
		def add_action(action)
			super
			invalidate_all
		end
		def add_syntax(syntax)
			super
			invalidate_all
		end
		def invalidate_all
      StoryWithSubplots.invalidate_for self
		end
	end
	
	module Featurable
		# Access content in the Story and all Subplots featuring this entity.
		def plot
			story = super
			StoryWithSubplots.for story, self
		end
	end

  module Subplotted
    def plot
      subplot = super
      story = subplot.story
      StoryWithSubplots.join [story, subplot]
    end
  end
  
end
