# TODO: JSON support is currently experimental.
#require 'gamefic/entityloader'
require 'gamefic/stage'
require 'gamefic/tester'
require 'gamefic/source'
require 'gamefic/script'
require 'gamefic/query'

module Gamefic

  class Plot
    autoload :SceneMount, 'gamefic/plot/scene_mount'
    autoload :CommandMount, 'gamefic/plot/command_mount'
    autoload :Entities, 'gamefic/plot/entities'
    #autoload :QueryMount, 'gamefic/plot/query_mount'
    autoload :ArticleMount, 'gamefic/plot/article_mount'
    autoload :YouMount, 'gamefic/plot/you_mount'
    autoload :Snapshot, 'gamefic/plot/snapshot'
    autoload :Host, 'gamefic/plot/host'
    autoload :Players, 'gamefic/plot/players'
    autoload :Playbook, 'gamefic/plot/playbook'

    attr_reader :commands, :imported_scripts, :rules, :asserts, :source
    # TODO Metadata could use better protection
    attr_accessor :metadata
    include Stage
    mount Gamefic, Tester, Players, SceneMount, CommandMount, Entities,
      ArticleMount, YouMount, Snapshot, Host
    expose :script, :introduction, :assert_action,
      :on_update, :on_player_update, :entities, :on_ready, :on_player_ready,
      :players, :metadata, :playbook
    
    # @param [Source::Base]
    def initialize(source = nil)
      @source = source || Source::Text.new({})
      @ready_procs = []
      @update_procs = []
      @player_ready = []
      @player_procs = []
      @working_scripts = []
      @imported_scripts = []
      @asserts = {}
      #@default_scene = :active
      @subplots = []
      @running = false
      @playbook = Playbook.new
      post_initialize
    end

    def playbook
      @playbook ||= Playbook.new
    end

    def running?
      @running
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
    
    # Get an Array of the Plot's current Syntaxes.
    #
    # @return [Array<Syntax>]
    def syntaxes
      playbook.syntaxes
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
            
    # Prepare the Plot for the next turn of gameplay.
    # This method is typically called by the Engine that manages game execution.
    def ready
      @running = true
      @ready_procs.each { |p| p.call }
      # Prepare player scenes for the update.
      p_players.each { |player|
        this_scene = player.next_scene || player.scene
        player.cue nil
        player.cue this_scene unless player.scene == this_scene
        @player_ready.each { |block|
          block.call player
        }
      }
    end
    
    # Update the Plot's current turn of gameplay.
    # This method is typically called by the Engine that manages game execution.
    def update
      p_players.each { |p| process_input p }
      p_entities.each { |e| e.update }
      p_players.each { |player| update_player player }
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
        #scenes[player.scene].finish player, line
        player.scene.finish player, line
      end
    end

    def update_player player
      @player_procs.each { |proc|
        proc.call player
      }
    end

  end

end
