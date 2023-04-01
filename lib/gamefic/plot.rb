# frozen_string_literal: true

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

    include World
    include Scriptable
    # @!parse extend Scriptable::ClassMethods
    include Snapshot
    include Host
    include Serialize

    # @param metadata [Hash]
    def initialize metadata: {}
      @metadata = metadata
      run_scripts
      theater
      define_static
      default_scene && default_conclusion # Make sure they exist
      playbook.freeze
      scenebook.freeze
    end

    def plot
      self
    end

    # Prepare the Plot for the next turn of gameplay.
    # This method is typically called by the engine that manages game
    # execution.
    #
    def ready
      subplots.each(&:ready)
      super
    end

    # Update the Plot's current turn of gameplay.
    # This method is typically called by the engine that manages game
    # execution.
    #
    def update
      subplots.each(&:update)
      subplots.delete_if(&:concluded?)
      super
    end

    def concluded?
      players.empty? && introduced?
    end

    def inspect
      "#<#{self.class}>"
    end
  end
end

module Gamefic
  # @yieldself [Gamefic::Plot]
  def self.script &block
    Gamefic::Plot.script &block
  end
end
