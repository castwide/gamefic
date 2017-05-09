module Gamefic
  
  # The Base Scene is not intended for instantiation. Other Scene classes
  # should inherit from it.
  #
  class Scene::Base
    attr_reader :actor
    attr_reader :input
    attr_writer :type
    attr_writer :prompt

    def initialize actor
      @actor = actor
      self.class.initialize_block.call @actor, self unless self.class.initialize_block.nil?
    end

    def on_finish &block
      @finish_block = block
    end

    def finish
      @input = @actor.queue.shift
      @finish_block.call @actor, self unless @finish_block.nil?
    end

    def self.subclass &block
      c = Class.new(self) do
        on_initialize &block
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
      @type ||= self.class.type
    end

    def self.on_initialize &block
      @initialize_block = block
    end

    class << self
      def initialize_block
        @initialize_block
      end

      def type
        'Base'
      end
    end
  end

end
