# TODO: JSON support is currently experimental.
#require 'gamefic/entityloader'
require 'gamefic/stage'
require 'gamefic/tester'
require 'gamefic/describable_articles'
require 'gamefic/source'
require 'gamefic/script'

module Gamefic

  class Plot
    autoload :SceneMount, 'gamefic/plot/scene_mount'
    autoload :CommandMount, 'gamefic/plot/command_mount'
    autoload :EntityMount, 'gamefic/plot/entity_mount'
    attr_reader :commands, :imported_scripts, :rules, :asserts, :finishes, :source
    attr_accessor :default_scene
    include Stage
    mount OptionMap, DescribableArticles, Tester, SceneMount, CommandMount, EntityMount
    expose :import, :introduction, :assert_action, :on_update, :on_player_update, :entities, :passthru
    def initialize(source = nil)
      @source = source || Source.new
      @commands = Hash.new
      @syntaxes = Array.new
      @update_procs = Array.new
      @player_procs = Array.new
      @working_scripts = Array.new
      @imported_scripts = Array.new
      @imported_identifiers = Array.new
      @entities = Array.new
      @players = Array.new
      @asserts = Hash.new
      @finishes = Hash.new
      @default_scene = :active
      post_initialize
    end
    def actions_with_verb(verb)
      @commands[verb].clone || []
    end
    def imported_scripts
      @imported_scripts ||= []
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
      ['', '.plot', '.rb'].each { |ext|
        if File.exist?(script + ext)
          stage File.read(script + ext), script + ext
          return
        end
      }
      raise "File not found: #{script}"
    end
    
    def import script
      if script[-1] == "*"
        source.search(script[0..-2]).each { |file|
          import file
        }
      else
        imported_script = source.export(script)
        if imported_script.nil?
          raise "Import not found: #{script}"
        end
        if !@working_scripts.include?(imported_script) and !imported_scripts.include?(imported_script)
          @working_scripts.push imported_script
          stage imported_script.read, imported_script.absolute
          @working_scripts.pop
          imported_scripts.push imported_script
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
  end

end
