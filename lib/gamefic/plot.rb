require 'gamefic/query'

module Gamefic
  # A plot controls the game narrative and manages the world model.
  # Authors typically build plots through scripts that are executed in a
  # special container called a stage. All of the elements that compose the
  # narrative (characters, locations, scenes, etc.) reside in the stage's
  # scope. Game engines use the plot to receive game data and process user
  # input.
  #
  class Plot
    autoload :Snapshot,  'gamefic/plot/snapshot'
    autoload :Darkroom,  'gamefic/plot/darkroom'
    autoload :Host,      'gamefic/plot/host'

    # @return [Hash]
    attr_reader :metadata

    attr_reader :static

    include World
    include Scriptable
    # @!parse extend Scriptable::ClassMethods
    include Snapshot
    include Host
    include Serialize

    exclude_from_serial [:@static]

    # @param structure [Gamefic::Structure]
    # @param metadata [Hash]
    def initialize metadata: {}
      current = Gamefic::Serialize.instances
      @metadata = metadata
      run_scripts
      @static = [self] + (Gamefic::Serialize.instances - current)
    end

    def player_class cls = nil
      @player_class = cls unless cls.nil?
      @player_class ||= Gamefic::Actor
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
      call_ready
      call_player_ready
      subplots.each { |s| s.ready }
      players.each do |p|
        p.state.replace(
          p.scene.state
          .merge({
            messages: p.messages,
            last_prompt: p.last_prompt,
            last_input: p.last_input,
            queue: p.queue
          })
          .merge(p.state)
        )
        p.output.replace(p.state)
        p.state.clear
      end
    end

    # Update the Plot's current turn of gameplay.
    # This method is typically called by the Engine that manages game
    # execution.
    #
    def update
      entities.each { |e| e.flush }
      call_before_player_update
      players.each do |p|
        p.performed nil
        next unless p.scene
        p.last_input = p.queue.last
        p.last_prompt = p.scene.prompt
        p.scene.update
        if p.scene.is_a?(Scene::Conclusion)
          player_conclude_procs.each do |proc|
            proc.call p
          end
        end
      end
      call_player_update
      call_update
      subplots.each { |s| s.update unless s.concluded? }
      subplots.delete_if { |s| s.concluded? }
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
  end
end

module Gamefic
  # @yieldself [Gamefic::Plot]
  def self.script &block
    Gamefic::Plot.script &block
  end
end
