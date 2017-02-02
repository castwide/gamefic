# TODO: JSON support is currently experimental.
#require 'gamefic/entityloader'
require 'gamefic/stage'
require 'gamefic/tester'
require 'gamefic/source'
require 'gamefic/script'
require 'gamefic/query'
require 'gamefic/subplot'

module Gamefic

  class Plot
    autoload :SceneMount, 'gamefic/plot/scene_mount'
    autoload :CommandMount, 'gamefic/plot/command_mount'
    autoload :EntityMount, 'gamefic/plot/entity_mount'
    autoload :QueryMount, 'gamefic/plot/query_mount'
    autoload :ArticleMount, 'gamefic/plot/article_mount'
    autoload :YouMount, 'gamefic/plot/you_mount'
    autoload :Snapshot, 'gamefic/plot/snapshot'
    
    attr_reader :commands, :imported_scripts, :rules, :asserts, :source
    # TODO Metadata could use better protection
    attr_accessor :default_scene, :metadata
    include Stage
    # TODO This include is only here to make the module's methods visible in the IDE.
    # Gamefic Studio has a PlotStageMetaMapper that handles it, but it doesn't run if
    # the plugin isn't activated.
    #include Gamefic, Tester, SceneMount, CommandMount, EntityMount, QueryMount, ArticleMount, YouMount, Snapshot
    mount Gamefic, Tester, SceneMount, CommandMount, EntityMount, QueryMount,
      ArticleMount, YouMount, Snapshot, Subplot::Host
    expose :script, :introduction, :assert_action,
      :on_update, :on_player_update, :entities, :on_ready, :on_player_ready,
      :players, :scenes, :metadata
    
    # @param [Source::Base]
    def initialize(source = nil)
      @source = source || Source::Text.new({})
      @commands = {}
      @syntaxes = []
      @ready_procs = []
      @update_procs = []
      @player_ready = []
      @player_procs = []
      @working_scripts = []
      @imported_scripts = []
      @entities = []
      @players = []
      @asserts = {}
      @default_scene = :active
      @subplots = []
      post_initialize
    end

    def scenes
      if @scenes.nil?
        @scenes = {}
        @scenes[:active] = Scene::Active.new
        @scenes[:concluded] = Scene::Conclusion.new
      end
      @scenes
    end
    
    def concluded?(actor)
      scenes[actor.scene].kind_of?(Scene::Conclusion)
    end
    
    # Get an Array of all Actions defined in the Plot.
    #
    # @return [Array<Action>]
    def actions
      @commands.values.flatten
    end
    
    # Get an Array of all Actions associated with the specified verb.
    #
    # @param verb [Symbol] The Symbol for the verb (e.g., :go or :look)
    # @return [Array<Action>] The verb's associated Actions
    def actions_with_verb(verb)
      @commands[verb].clone || []
    end
    
    # Get an Array of all scripts that have been imported into the Plot.
    #
    # @return [Array<Script>] The imported scripts
    def imported_scripts
      @imported_scripts ||= []
    end
    
    # Add a Block to be executed for the given verb.
    # If the block returns false, the Action is cancelled.
    #
    # @example Require the player to have a property enabled before performing the Action.
    #   assert_action :authorize do |actor, verb, arguments|
    #     if actor[:can_authorize] == true
    #       true
    #     else
    #       actor.tell "You don't have permission to use the authorize command."
    #       false
    #     end
    #   end
    #
    # @yieldparam [Character] The character performing the Action.
    # @yieldparam [Symbol] The verb associated with the Action.
    # @yieldparam [Array] The arguments that will be passed to the Action's #execute method.
    def assert_action name, &block
      @asserts[name] = Assert.new(name, &block)
    end
    
    def post_initialize
      # TODO: Should this method be required by extended classes?
    end
    
    # Get an Array of the Plot's current Entities.
    #
    # @return [Array<Entity>]
    def entities
      @entities.clone
    end
    
    # Get an Array of the Plot's current Syntaxes.
    #
    # @return [Array<Syntax>]
    def syntaxes
      @syntaxes.clone
    end
    
    # Get an Array of current players.
    #
    # @return [Array<Character>] The players.
    def players
      @players.clone
    end
    
    # Add a block to be executed on preparation of every turn.
    # Each on_ready block is executed once per turn, as opposed to
    # on_player_ready blocks, which are executed once for each player.
    #
    # @example Increment a turn counter
    #   turn = 0
    #   on_ready do
    #     turn += 1
    #   end
    #
    def on_ready(&block)
      @ready_procs.push block
    end
    
    # Add a block to be executed after the Plot is finished updating a turn.
    # Each on_update block is executed once per turn, as opposed to
    # on_player_update blocks, which are executed once for each player.
    def on_update(&block)
      @update_procs.push block
    end
    
    # Add a block to be executed when a player is added to the game.
    # Each Plot can only have one introduction. Subsequent calls will
    # overwrite the existing one.
    #
    # @example Welcome the player to the game
    #   introduction do |actor|
    #     actor.tell "Welcome to the game!"
    #   end
    #
    # @yieldparam [Character]
    def introduction (&proc)
      @introduction = proc
    end
    
    # Introduce a player to the game.
    # This method is typically called by the Engine that manages game execution.
    def introduce(player)
      player.extend Subplot::Feature
      player.cue :active
      @players.push player
      @introduction.call(player) unless @introduction.nil?
    end
    
    # Prepare the Plot for the next turn of gameplay.
    # This method is typically called by the Engine that manages game execution.
    def ready
      @ready_procs.each { |p| p.call }
      # Prepare player scenes for the update.
      @players.each { |player|
        this_scene = player.next_scene || player.scene
        player.prepare nil
        player.cue this_scene unless player.scene == this_scene
        @player_ready.each { |block|
          block.call player
        }
      }
    end
    
    # Update the Plot's current turn of gameplay.
    # This method is typically called by the Engine that manages game execution.
    def update
      @players.each { |p| process_input p }
      @entities.each { |e| e.update }
      @players.each { |player| update_player player }
      @update_procs.each { |p| p.call }
    end

    def tell entities, message, refresh = false
      entities.each { |entity|
        entity.tell message, refresh
      }
    end

    # Load a script into the current Plot.
    # This method is similar to Kernel#require, except that the script is
    # evaluated within the Plot's context via #stage.
    #
    # @param path [String] The path to the script being evaluated
    # @return [Boolean] true if the script was loaded by this call or false if it was already loaded.
    def script path
      imported_script = source.export(path)
      if imported_script.nil?
        raise "Script not found: #{path}"
      end
      if !@working_scripts.include?(imported_script) and !imported_scripts.include?(imported_script)
        @working_scripts.push imported_script
        stage imported_script.read, imported_script.absolute_path
        @working_scripts.pop
        imported_scripts.push imported_script
        true
      else
        false
      end
    end
    
    # Add a block to be executed for each player when the Plot prepares them
    # for the next turn in the game.
    #
    # @yieldparam [Character]
    def on_player_ready &block
      @player_ready.push block
    end
    
    # Add a block to  be executed for each player after they have completed a
    # turn in the game.
    #
    # @yieldparam [Character]
    def on_player_update &block
      @player_procs.push block
    end

    private

    def process_input player
      line = player.queue.shift
      if !line.nil?
        scenes[player.scene].finish player, line
      end
    end

    def update_player player
      @player_procs.each { |proc|
        proc.call player
      }
    end

    def rem_entity(entity)
      @entities.delete(entity)
      @players.delete(entity)
    end

    def add_syntax syntax
      if @commands[syntax.verb] == nil
        raise "Action \"#{syntax.verb}\" does not exist."
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
      @commands[action.verb] ||= []
      @commands[action.verb].unshift action
      @commands[action.verb].sort! { |a, b|
        if a.specificity == b.specificity
          # Newer action takes precedence
          b.order_key <=> a.order_key
        else
          # Higher specificity takes precedence
          b.specificity <=> a.specificity
        end
      }
      generate_default_syntax action
    end

    def generate_default_syntax action
      user_friendly = action.verb.to_s.gsub(/_/, ' ')
      args = []
      used_names = []
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
      add_syntax Syntax.new(user_friendly.strip, "#{action.verb} #{args.join(' ')}")
    end

    def rem_action(action)
      @commands[action.verb].delete(action)
    end

    def rem_syntax(syntax)
      @syntaxes.delete syntax
    end
    
    def add_entity(entity)
      @entities.push entity
    end
  end

end
