require 'gamefic/query'

module Gamefic
  # A plot controls the game narrative and manages the world model.
  # Authors typically build plots through scripts that are executed in a
  # special container called a stage. All of the elements that compose the
  # narrative (characters, locations, scenes, etc.) reside in the stage's
  # scope. Game engines use the plot to receive game data and process user
  # input.
  #
  class Plot #< Container
    autoload :Snapshot,  'gamefic/plot/snapshot'
    autoload :Darkroom,  'gamefic/plot/darkroom'
    autoload :Host,      'gamefic/plot/host'
    autoload :Script,    'gamefic/plot/script'
    autoload :Source,    'gamefic/plot/source'

    # @return [Gamefic::Source]
    attr_reader :source

    # TODO: Metadata could use better protection
    attr_accessor :metadata

    include World
    include Snapshot
    include Host

    # @param structure [Gamefic::Structure]
    def initialize structure: Gamefic::BASE
      @source = source || Source.new
      @working_scripts = []
      @imported_scripts = []
      @running = false
      post_initialize
      structure.blocks.each { |blk| stage &blk }
    end

    def player_class cls = nil
      @player_class = cls unless cls.nil?
      @player_class
    end

    def running?
      @running
    end

    # Get an Array of all scripts that have been imported into the Plot.
    #
    # @return [Array<Gamefic::Script::Base>]
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
    # This method is typically called by the Engine that manages game
    # execution.
    #
    def ready
      playbook.freeze
      @running = true
      # Call the initial state to make sure it's set
      initial_state
      call_ready
      call_player_ready
      p_subplots.each { |s| s.ready }
    end

    # Update the Plot's current turn of gameplay.
    # This method is typically called by the Engine that manages game
    # execution.
    #
    def update
      entities.each { |e| e.flush }
      call_before_player_update
      p_players.each do |p|
        p.performed nil
        p.last_input = p.queue.last
        p.last_prompt = p.scene.prompt
        p.scene.update
      end
      p_entities.each { |e| e.update }
      call_player_update
      call_update
      p_subplots.each { |s| s.update unless s.concluded? }
      p_subplots.delete_if { |s| s.concluded? }
    end

    # Send a message to a group of entities.
    #
    # @param entities [Array<Entity>]
    # @param message [String]
    def tell entities, message
      entities.each { |entity|
        entity.tell message
      }
    end

    # Load a script into the current Plot.
    # This method is similar to Kernel#require, except that the script is
    # evaluated within the Plot's context via #stage.
    #
    # @raise [LoadError] if script could not be found
    # @param path [String] The path to the script being evaluated
    # @return [Boolean] true if the script was loaded by this call or false if it was already loaded.
    def script path
      imported_script = source.export(path)
      if imported_script.nil?
        raise LoadError.new("cannot load script -- #{path}")
      end
      if !@working_scripts.include?(imported_script) and !imported_scripts.include?(imported_script)
        @working_scripts.push imported_script
        # HACK: Arguments need to be in different order if source returns proc
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
