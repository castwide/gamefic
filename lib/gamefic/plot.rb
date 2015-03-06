require 'gamefic/character/state'
# TODO: JSON support is currently experimental.
#require 'gamefic/entityloader'

module Gamefic

  def self.bind(plot)
    mod = Module.new do
      include Gamefic
      def self.bind(plot)
        @@plot = plot
      end
      def self.get_binding
        binding
      end
      # In the MRI, import methods in plots get passed through to
      # method_missing without a hitch. In JRuby, it doesn't work as expected,
      # most likely because it gets confused with Java import.
      def self.import *args
        @@plot.import *args
      end
      def self.load *args
        @@plot.load *args
      end
      def self.method_missing(method_name, *args, &block)
        if @@plot.respond_to?(method_name)
          if method_name == :action or method_name == :respond or method_name == :assert_action or method_name == :finish_action or method_name == :meta
            result = @@plot.send method_name, *args, &block
            parts = caller[0].split(':')[0..-2]
            line = parts.pop
            file = parts.join(':').gsub(/\/+/, '/')
            # The caller value shouldn't really be user-definable, so we're
            # injecting it into the instance variable instead of defining a
            # writer method in the receiver.
            result.instance_variable_set(:@caller, "#{file}, line #{line}")
          else
            @@plot.send method_name, *args, &block
          end
        elsif Gamefic.respond_to?(method_name)
          Gamefic.send method_name, *args, &block
        else
          raise "Unknown method #{method_name} in plot script"
        end
      end
    end
    mod.bind plot
    mod
  end
  
	class Plot
		attr_reader :scenes, :commands, :conclusions, :imported_scripts, :rules, :asserts, :finishes, :states, :game_directory
		attr_accessor :story
    include OptionMap
		def commandwords
			words = Array.new
			@syntaxes.each { |s|
        word = s.first_word
				words.push(word) if !word.nil?
			}
			words.uniq
		end
		def initialize config = nil
      if config.nil?
        @import_paths = [Gamefic::GLOBAL_IMPORT_PATH]
      elsif config.kind_of?(Array)
        @import_paths = config
      else
        @import_paths = config.import_paths
      end
      
			@scenes = Hash.new
			@commands = Hash.new
			@syntaxes = Array.new
			@conclusions = Hash.new
			@update_procs = Array.new
      @player_procs = Array.new
			@imported_scripts = Array.new
      @imported_identifiers = Array.new
			@entities = Array.new
      @players = Array.new
      @asserts = Hash.new
      @finishes = Hash.new
      @states = Hash.new
      @states[:active] = CharacterState::Active.new
      @states[:concluded] = CharacterState::Concluded.new
      @game_directory = nil
			post_initialize
		end
    def assert_action name, &block
      @asserts[name] = Assert.new(name, &block)
    end
    def finish_action name, &block
      @finishes[name] = block
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
		def make(cls, args = {}, &block)
			ent = cls.new(self, args, &block)
			if ent.kind_of?(Entity) == false
				raise "Invalid entity class"
			end
			ent
		end
    def pause name, *args, &block
      @states[name] = CharacterState::Paused.new(*args, &block)
    end
    def prompt name, *args, &block
      @states[name] = CharacterState::Prompted.new(*args, &block)
    end
    def yes_or_no name, *args, &block
      @states[name] = CharacterState::YesOrNo.new(*args, &block)
    end
    def multiple_choice name, *args, &block
      @states[name] = CharacterState::MultipleChoice.new(*args, &block)
    end
		def syntax(*args)
      xlate *args
		end
		def xlate(*args)
			syn = Syntax.new(self, *args)
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
      @players.push player
			if @introduction != nil
				@introduction.call(player)
			end
      if player.parent.nil?
        rooms = entities.that_are(Room)
        if rooms.length == 0
          room = make(Room, :name => 'nowhere')
          player.parent = room
        else
          player.parent = rooms[0]
        end
      end
		end
		def conclude(player, key = nil)
			if key != nil and @conclusions[key]
				@conclusions[key].call(player)
        player.state = :concluded
			end
		end
		def cue actor, scene
			@scenes[scene].call(actor)
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
      @players.each { |player|
        @player_procs.each { |proc|
          proc.call player
        }
      }
		end

		def tell entities, message, refresh = false
			entities.each { |entity|
				entity.tell message, refresh
			}
		end

    def load script
      if @game_directory.nil?
        @game_directory = File.dirname(script)
      else
        script = "#{@game_directory}/#{script}"
      end
      ext = File.extname(script)
      if ext == "" || !File.exist?(script)
        if File.exist?(script + ".plot")
          ext = ".plot"
          script += ".plot"
        elsif File.exist?(script + ".rb")
          ext = ".rb"
          script += ".rb"
        elsif File.exist?(script + ".json")
          ext = ".json"
          script += ".json"
        end
      end
      case ext
        when ".plot", ".rb"
          code = File.read(script)
          eval code, ::Gamefic.bind(self).get_binding, script, 1
        # TODO: JSON support is currently experimental.
        #when ".gjson"
        #  EntityLoader.load File.read(script), self
        else
          raise "Invalid file type"
      end
    end
    
    def import script
      script.gsub!(/\/+/, '/')
      if script[0, 1] == '/'
        script = script[1..-1]
      end
      if script[-2, 2] == '/*'
        # Import all matching scripts in all paths
        directory = script[0..-3]
        resolved = directory
        @import_paths.each { |path|
          Dir["#{path}/#{script}"].each { |f|
            import f[path.length..-1]
          }
        }
      else
        resolved = script
        base = nil
        found = false
        @import_paths.each { |path|
          if File.file?("#{path}/#{resolved}")
            base = path
            found = true
          elsif File.file?("#{path}/#{resolved}.plot")
            base = path
            resolved = resolved + '.plot'
            found = true
          elsif File.file?("#{path}/#{resolved}.rb")
            base = path
            resolved = resolved + '.rb'
            found = true
          end
          break if found
        }
        if found
          if @imported_identifiers.include?(resolved) == false
            code = File.read("#{base}/#{resolved}")
            @imported_identifiers.push resolved
            eval code, Gamefic.bind(self).get_binding, "#{base}/#{resolved}", 1
            @imported_scripts.push Imported.new(base, resolved)
          end
        else
          raise "Unavailable import: #{script}"
        end
      end
    end
    def on_player_update &block
      @player_procs.push block
    end
    def pick(description)
      result = Query.match(description, entities)
      if result.objects.length == 0
        raise "Unable to find entity from '#{description}'"
      elsif result.objects.length > 1
        raise "Ambiguous entities found from '#{description}'"
      end
      result.objects[0]
    end
    def _(description)
      pick description
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
			if @commands[syntax.action] == nil
				raise "Action \"#{syntax.action}\" does not exist"
			end
      # Delete duplicate syntaxes
      @syntaxes = @syntaxes.delete_if { |existing|
        existing == syntax
      }
			@syntaxes.unshift syntax
			@syntaxes.sort! { |a, b|
				if a.token_count == b.token_count
					# For syntaxes of the same length, length of action takes precedence
					b.first_word <=> a.first_word
				else
					b.token_count <=> a.token_count
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
      user_friendly = action.command.to_s
      args = Array.new
      used_names = Array.new
      action.queries.each { |c|
        num = 1
        new_name = ":var"
        while used_names.include? new_name
          num = num + 1
          new_name = ":var#{num}"
        end
        used_names.push new_name
        user_friendly += " #{new_name}"
        args.push new_name
      }
      Syntax.new self, user_friendly.strip, "#{action.command} #{args.join(' ')}"
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
    class Imported
      attr_reader :base, :relative
      def initialize base, relative
        @base = base
        @relative = relative
      end
      def absolute
        "#{base}/#{relative}".gsub(/\/+/, '/')
      end
    end
  end

end
