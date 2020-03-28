module Gamefic
  # The Base Scene is not intended for instantiation. Other Scene classes
  # should inherit from it.
  #
  class Scene::Base
    extend Gamefic::Index

    # The scene's primary actor.
    #
    # @return [Gamefic::Actor]
    attr_reader :actor

    # A human-readable string identifying the type of scene.
    #
    # @return [String]
    attr_writer :type

    # The text to display when requesting input.
    #
    # @return [String]
    attr_writer :prompt

    # The input received from the actor.
    #
    # @return [String]
    attr_reader :input

    # @return [Hash{Symbol => Object}]
    attr_reader :data

    def initialize actor, **data
      @actor = actor
      @data = data
      post_initialize
    end

    # A shortcut for the #data hash.
    #
    # @param key [Symbol]
    # @return [Object]
    def [] key
      data[key]
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
      @actor.entered self if tracked?
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

    def tracked?
      self.class.tracked?
    end

    def tracked= bool
      self.class.tracked = bool
    end

    class << self
      attr_writer :tracked

      def start_block
        @start_block
      end

      def tracked?
        @tracked ||= false
      end
    end
  end
end
