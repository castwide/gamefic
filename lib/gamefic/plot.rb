module Gamefic

	class Plot
		attr_reader :scenes, :commands, :conclusions, :declared_scripts
		attr_accessor :story
		def commandwords
			words = Array.new
			@syntaxes.each { |s|
				words.push(s.template.split_words[0])
			}
			words.uniq
		end
		def initialize
			@scenes = Hash.new
			@commands = Hash.new
			@syntaxes = Array.new
			@conclusions = Hash.new
			@update_procs = Array.new
			@declared_scripts = Array.new
			@entities = Array.new
			post_initialize
		end
		def post_initialize
			Action.defaults.each {|a|
				add_action a
			}
			Syntax.defaults.each {|s|
				add_syntax s
			}
		end
		#def require_defaults
			#Dir[File.dirname(__FILE__) + '/entity_ext/*.rb'].each do |file|
			#	require file
			#end
			#Dir[File.dirname(__FILE__) + '/action_ext/*.rb'].each do |file|
			#	require_script file
			#end
		#end
		def action(command, *queries, &proc)
			act = Action.new(self, command, *queries, &proc)
		end
		def respond(command, *queries, &proc)
			self.action(command, *queries, &proc)
		end
		def entity(cls, args)
			ent = cls.new(self, args)
			if ent.kind_of?(Entity) == false
				raise "Invalid entity class"
			end
			#@entities.push ent
			ent
		end
		def make(cls, args = {})
			self.entity(cls, args)
		end
		def syntax(*args)
			syn = Syntax.new(self, *args)
			@syntaxes.push syn
			syn
		end
		def xlate(*args)
			syntax(*args)
		end
		#def add_entity(entity)
		#	if @entities.include?(entity) == false
		#		@entities.push entity
		#	end
		#end
		def rem_entity(entity)
			@entities.delete(entity)
		end
		def entities
			@entities.clone
		end
		def syntaxes
			@syntaxes.clone
		end
		def on_update(&block)
			@update_procs.push block
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
			if @introduction != nil
				@introduction.call(player)
			end
		end
		def conclude(player, key = nil)
			if key != nil and @conclusions[key]
				@conclusions[key].call(player)
			end
		end
		def cue scene
			@scenes[scene].call
		end
		def passthru
			Director::Delegate.passthru
		end
		def update
			@update_procs.each { |p|
				p.call
			}
			#@entities.flatten.each { |e|
      @entities.each { |e|
				#recursive_update e
				e.update
			}
		end
		def tell entities, message, refresh = false
			entities.each { |entity|
				entity.tell message, refresh
			}
		end
		def load_script filename
			story = self
			eval File.read(filename), nil, filename, 1
		end
		def require_script filename
			if @declared_scripts.include?(filename) == false
				@declared_scripts.push(filename)
				load_script filename
			end
		end
		private
		def recursive_update(entity)
			entity.update
			entity.children.each { |e|
				recursive_update e
			}
		end	
		def add_syntax syntax
			if @commands[syntax.command] == nil
				raise "Action \"#{syntax.command}\" does not exist"
			end
			@syntaxes.unshift syntax
			@syntaxes.sort! { |a, b|
				al = a.template.split_words.length
				bl = b.template.split_words.length
				if al == bl
					# For syntaxes of the same length, creation order takes precedence
					0
				else
					bl <=> al
				end
			}			
		end
		def add_action(action)
			if (@commands[action.command] == nil)
				@commands[action.command] = Array.new
			end
			@commands[action.command].unshift action
			@commands[action.command].sort! { |a, b|
				if a.specificity == b.specificity
					# For actions of the same length, creation order takes precedence
					0
				else
					b.specificity <=> a.specificity
				end
			}
			user_friendly = action.command.to_s.sub(/_/, ' ')
			args = Array.new
			used_names = Array.new
			action.queries.each { |c|
				num = 1
				new_name = "var"
				while used_names.include? new_name
					num = num + 1
					new_name = "var#{num}"
				end
				used_names.push new_name
				user_friendly += " :#{new_name}"
				args.push new_name.to_sym
			}
			Syntax.new self, *[user_friendly, action.command] + args
		end
		def add_entity(entity)
			@entities.push entity
		end
	end

end
