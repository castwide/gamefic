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

    def on_finish &block
      @finish_block = block
    end

    def update
      @input = actor.queue.shift
      finish
    end

    def start
      self.class.start_block.call @actor, self unless self.class.start_block.nil?
    end

    def finish
      @finish_block.call @actor, self unless @finish_block.nil?
      @finished = true
    end

    def finished?
      @finished ||= false
    end

    def flush
      @state.clear
    end

    def state
      {
        scene: type, prompt: prompt
      }
    end

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

    def type
      @type ||= 'Scene'
    end

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
