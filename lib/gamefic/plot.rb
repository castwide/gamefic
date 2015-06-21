# TODO: JSON support is currently experimental.
#require 'gamefic/entityloader'
require 'gamefic/stage'
require 'gamefic/tester'
require 'gamefic/mount/scene'
require 'gamefic/mount/command'
require 'gamefic/mount/entity'

module Gamefic

  class Plot
    attr_reader :commands, :imported_scripts, :rules, :asserts, :finishes, :game_directory
    attr_accessor :default_scene
    include Stage
    mount OptionMap, DescribableArticles, Tester, SceneMount, CommandMount, EntityMount
    expose :import, :introduction, :assert_action, :on_update, :on_player_update, :entities, :passthru
    def initialize config = nil
      if config.nil?
        @import_paths = [Gamefic::GLOBAL_IMPORT_PATH]
      elsif config.kind_of?(Array)
        @import_paths = config
      else
        @import_paths = config.import_paths
      end
      
      @commands = Hash.new
      @syntaxes = Array.new
      @update_procs = Array.new
      @player_procs = Array.new
      @imported_scripts = Array.new
      @imported_identifiers = Array.new
      @entities = Array.new
      @players = Array.new
      @asserts = Hash.new
      @finishes = Hash.new
      @default_scene = :active      
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
    def introduce(player)
      @players.push player
      if @introduction != nil
        @introduction.call(player)
      end
      if player.parent.nil?
        #rooms = entities.that_are(Room)
        #if rooms.length == 0
        #  room = make(Room, :name => 'nowhere')
        #  player.parent = room
        #else
        #  player.parent = rooms[0]
        #end
      end
      # TODO: There should probably be a default state specified
      # by the plot, which would be :active by default. We could
      # get it like player.cue nil.
      if player.scene.nil?
        cue player, default_scene
      end
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
          #eval code, ::Gamefic.bind(self).get_binding, script, 1
          stage code, script
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
            #eval code, Gamefic.bind(self).get_binding, "#{base}/#{resolved}", 1
            stage code, resolved
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
