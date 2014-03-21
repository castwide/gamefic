module Gamefic

  def self.bind(plot)
    mod = Module.new do
      def self.bind(plot)
        @@plot = plot
      end
      def self.get_binding
        binding
      end
      def self.method_missing(name, *args, &block)
        if @@plot.respond_to?(name)
          @@plot.send name, *args, &block
        end
      end
    end
    mod.bind plot
    mod.get_binding
  end
  
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
      # TODO: Should this method be required by extended classes?
		end
		def action(command, *queries, &proc)
			act = Action.new(self, command, *queries, &proc)
		end
		def respond(command, *queries, &proc)
			self.action(command, *queries, &proc)
		end
		def make(cls, args = {})
			ent = cls.new(self, args)
			if ent.kind_of?(Entity) == false
				raise "Invalid entity class"
			end
			ent
		end
		def syntax(*args)
		end
		def xlate(*args)
			syn = Syntax.new(self, *args)
			@syntaxes.push syn
			syn
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
        player.state = GameOverState.new(player)
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
      @entities.each { |e|
				e.update
			}
		end

		def tell entities, message, refresh = false
			entities.each { |entity|
				entity.tell message, refresh
			}
		end

    def load script
      @source_directory = File.dirname(script)
      eval File.read(script), ::Gamefic.bind(self), script, 1
    end
    
    def import script
      if script[-2, 2] == '/*'
        directory = script[0..-3]
        resolved = @source_directory + '/import/' + directory
        if !File.directory?(resolved)
          $LOAD_PATH.each { |path|
            if File.directory?("#{path}/gamefic/import/#{directory}")
              resolved = "#{path}/gamefic/import/#{directory}"
              break
            end
          }
        end
        Dir[resolved + '/*'].each do |file|
          if File.file?(file)
            new_import = directory + '/' + File.basename(file)[0..(File.extname(file).length * -1)-1]
            self.import new_import
          else
            # TODO: How to handle directories? Ignore them, probably
          end
        end
      else
        resolved = @source_directory + '/import/' + script
        if !File.file?(resolved)
          if File.file?(resolved + ".rb")
            resolved = resolved + ".rb"
          else
            $LOAD_PATH.each { |path|
              if File.file?("#{path}/gamefic/import/#{script}")
                resolved = "#{path}/gamefic/import/#{script}"
                break
              elsif File.file?("#{path}/gamefic/import/#{script}.rb")
                resolved = "#{path}/gamefic/import/#{script}.rb"
                break
              end
            }
          end
        end
        if @declared_scripts.include?(resolved) == false
          @declared_scripts.push(resolved)
          eval File.read(resolved), ::Gamefic.bind(self), resolved, 1
        end
      end
    end
    
		private
		def rem_entity(entity)
			@entities.delete(entity)
		end
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
          # Newer action takes precedence
          b.order_key <=> a.order_key
        else
          # Higher specificity takes precedence
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
    def rem_action(action)
      @commands[action.command].delete(action)
    end
    def rem_syntax(syntax)
      @syntaxes.delete syntax
    end
		def add_entity(entity)
			@entities.push entity
		end
  end

end
