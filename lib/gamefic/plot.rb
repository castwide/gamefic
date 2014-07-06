module Gamefic

  def self.bind(plot)
    mod = Module.new do
      def self.bind(plot)
        @@plot = plot
      end
      def self.get_binding
        binding
      end
      def self.method_missing(method_name, *args, &block)
        if @@plot.respond_to?(method_name)
          if method_name == :action or method_name == :respond
            result = @@plot.send method_name, *args, &block
            result.instance_variable_set(:@caller, caller[0])
          else
            @@plot.send method_name, *args, &block
          end
        elsif Gamefic.respond_to?(method_name)
          Gamefic.send method_name, *args, &block
        end
      end
    end
    mod.bind plot
    mod.get_binding
  end
  
  def self.safe_level
    @@safe_level ||= (RUBY_VERSION.split('.')[0].to_i < 2 ? 2 : 3)
  end
  
	class Plot
		attr_reader :scenes, :commands, :conclusions, :imported_scripts, :rules
		attr_accessor :story
    include OptionMap
		def commandwords
			words = Array.new
			@syntaxes.each { |s|
        word = s.template[0]
				words.push(word) if !word.kind_of?(Symbol)
			}
			words.uniq
		end
		def initialize
			@scenes = Hash.new
			@commands = Hash.new
			@syntaxes = Array.new
			@conclusions = Hash.new
			@update_procs = Array.new
      @available_scripts = Hash.new
			@imported_scripts = Array.new
			@entities = Array.new
      @rules = Hash.new
			post_initialize
		end
    def assert name, &block
      @rules[name] = Requirement.new self, name, &block
    end
		def post_initialize
      # TODO: Should this method be required by extended classes?
		end
		def meta(command, *queries, &proc)
			act = Meta.new(self, command, *queries, &proc)
		end
		def action(command, *queries, &proc)
			act = Action.new(self, command, *queries, &proc)
		end
		def respond(command, *queries, &proc)
			self.action(command, *queries, &proc)
		end
		def before(command, *queries, &proc)
			bef = Before.new(self, command, *queries, &proc)
		end
		def make(cls, args = {})
			ent = cls.new(self, args)
			if ent.kind_of?(Entity) == false
				raise "Invalid entity class"
			end
			ent
		end
		def syntax(*args)
      xlate *args
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
      if player.parent.nil?
        Proc.new {
          $SAFE = 3
          rooms = entities.that_are(Room)
          if rooms.length == 0
            room = make(Room, :name => 'nowhere')
            player.parent = room
          else
            player.parent = rooms[0]
          end
        }.call
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
    def pass requirement
      Director::Delegate.pass requirement
    end
    def deny requirement
      Director::Delegate.deny requirement
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

    def load script, with_libs = true
      code = File.read(script)
      code.untaint
      @source_directory = File.dirname(script)
      if with_libs == true
        $LOAD_PATH.reverse.each { |path|
          get_scripts path + '/gamefic/import'
        }
      end
      get_scripts @source_directory + '/import'
      proc {
        $SAFE = Gamefic.safe_level
        eval code, ::Gamefic.bind(self), script, 1
      }.call
    end
    
    def import script
      if script[-2, 2] == '/*'
        directory = script[0..-3]
        resolved = directory
        @available_scripts.each { |f, c|
          if f.start_with?(resolved)
            self.import f
          end
        }
      else
        resolved = script
        if !@available_scripts.has_key?(resolved)
          if @available_scripts.has_key?(resolved + '.rb')
            resolved = resolved + '.rb'
          end
        end
        if @available_scripts.has_key?(resolved)
          if @available_scripts[resolved] != nil
            script_object = @available_scripts[resolved]
            @available_scripts[resolved] = nil
            proc {
              $SAFE = Gamefic.safe_level
              @imported_scripts.push script_object
              eval script_object.code, Gamefic.bind(self), script_object.filename, 1
            }.call
          end
        else
          raise "Unavailable import: #{resolved}"
        end
      end
    end
    
		private
    def get_scripts(directory)
      Dir[directory + '/*'].each { |f|
        if File.directory?(f)
          get_scripts f
        else
          relative = f[(f.index('/import/')+8)..-1]
          @available_scripts[relative] = Script.new(f)
        end
      }
    end
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
				al = a.template.length
        if (a.command.nil?)
          al -= 1
        end
				bl = b.template.length
        if (b.command.nil?)
          bl -= 1
        end
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
      #if action.command != nil
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
        Syntax.new self, *[user_friendly.strip, action.command] + args
      #end
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
    class Script
      attr_reader :filename, :code
      def initialize filename
        @filename = filename
        @code = File.read(filename)
        @code.untaint
      end
    end
  end

end
