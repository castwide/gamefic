module Gamefic
  
  # The Base Scene is not intended for instantiation. Other Scene classes
  # should inherit from it.
  #
  class Scene::Base
    attr_reader :actor
    attr_writer :type
    attr_writer :prompt
    attr_reader :input

    def initialize actor
      @actor = actor
      post_initialize
    end

    def post_initialize
    end

    # Set a proc to be executed at the end of the scene.
    #
    def on_finish &block
      @finish_block = block
    end

    # Update the scene.
    #
    def update
      @input = actor.queue.shift
      finish
    end

    # Start the scene.
    #
    def start
      self.class.start_block.call @actor, self unless self.class.start_block.nil?
    end

    # Finish the scene.
    #
    def finish
      @finish_block.call @actor, self unless @finish_block.nil?
      @finished = true
    end

    # Determine whether the scene's execution is finished.
    #
    # @return [Boolean]
    def finished?
      @finished ||= false
    end

    # Get a hash that describes the current state of the scene.
    #
    # @return [Hash]
    def state
      {
        scene: type, prompt: prompt
      }
    end

    # @yieldparam [Class<Gamefic::Actor>]
    # @return [Class<Gamefic::Scene::Base>]
    def self.subclass &block
      c = Class.new(self) do
        on_start &block
      end
      c
    end

    # Get the prompt to be displayed to the user when accepting input.
    #
    # @return [String] The text to be displayed.
    def prompt
      @prompt ||= '>'
    end

    # Get a String that describes the type of scene.
    #
    # @return [String]
    def type
      @type ||= 'Scene'
    end

    # @yieldparam [Class<Gamefic::Scene::Base>]
    def self.on_start &block
      @start_block = block
    end

    class << self
      def start_block
        @start_block
      end
    end
  end

end
