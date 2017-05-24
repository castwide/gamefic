# TODO: JSON support is currently experimental.
#require 'gamefic/entityloader'
require 'gamefic/tester'
require 'gamefic/source'
require 'gamefic/script'
require 'gamefic/query'

module Gamefic

  class Plot
    autoload :Scenes,    'gamefic/plot/scenes'
    autoload :Commands,  'gamefic/plot/commands'
    autoload :Entities,  'gamefic/plot/entities'
    autoload :Articles,  'gamefic/plot/articles'
    autoload :YouMount,  'gamefic/plot/you_mount'
    autoload :Snapshot,  'gamefic/plot/snapshot'
    autoload :Host,      'gamefic/plot/host'
    autoload :Players,   'gamefic/plot/players'
    autoload :Playbook,  'gamefic/plot/playbook'
    autoload :Callbacks, 'gamefic/plot/callbacks'
    autoload :Theater,   'gamefic/plot/theater'

    attr_reader :commands, :imported_scripts, :source

    # TODO: Metadata could use better protection
    attr_accessor :metadata
    include Theater
    include Gamefic, Tester, Players, Scenes, Commands, Entities
    include Articles, YouMount, Snapshot, Host, Callbacks

    # @param source [Source::Base]
    def initialize(source = nil)
      @source = source || Source::Text.new({})
      @working_scripts = []
      @imported_scripts = []
      @running = false
      post_initialize
    end

    def player_class cls = nil
      @player_class = cls unless cls.nil?
      @player_class
    end

    # @return [Gamefic::Plot::Playbook]
    def playbook
      @playbook ||= Gamefic::Plot::Playbook.new
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
    
    def post_initialize
      # TODO: Should this method be required by extended classes?
    end
    
    # Get an Array of the Plot's current Syntaxes.
    #
    # @return [Array<Syntax>]
    def syntaxes
      playbook.syntaxes
    end
    
    # Prepare the Plot for the next turn of gameplay.
    # This method is typically called by the Engine that manages game execution.
    def ready
      playbook.freeze
      @running = true
      call_ready
      call_player_ready
      p_subplots.each { |s| s.ready }
    end
    
    # Update the Plot's current turn of gameplay.
    # This method is typically called by the Engine that manages game execution.
    def update
      entities.each { |e| e.flush }
      call_before_player_update
      p_players.each { |p|
        p.performed nil
        p.scene.update
      }
      p_entities.each { |e| e.update }
      call_player_update
      call_update
      p_subplots.each { |s| s.update unless s.concluded? }
      p_subplots.delete_if { |s| s.concluded? }
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
        raise LoadError.new("cannot load script -- #{path}")
      end
      if !@working_scripts.include?(imported_script) and !imported_scripts.include?(imported_script)
        @working_scripts.push imported_script
        # @hack Arguments need to be in different order if source returns proc
        if imported_script.read.kind_of?(Proc)
          stage &imported_script.read
        else
          stage imported_script.read, imported_script.absolute_path
        end
        @working_scripts.pop
        imported_scripts.push imported_script
        true
      else
        false
      end
    end
  end

end
