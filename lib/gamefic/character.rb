require 'gamefic/director'

module Gamefic
  class Character < Entity
    attr_reader :queue, :user
    # @return [Gamefic::Director::Order]
    attr_reader :last_order
    # @return [Entity,nil]
    attr_reader :last_object
    attr_accessor :object_of_pronoun
    
    serialize :scene
    
    def initialize(plot, args = {})
      @queue = Array.new
      super
      @buffer_stack = 0
      @buffer = ""
    end
    
    # Connect a User.
    #
    # @param user [User]
    def connect(user)
      @user = user
    end
    
    # Disconnect the current User.
    #
    def disconnect
      # TODO: We might need some cleanup here. Like, move the character out of the game, or set a timeout to allow dropped users to reconnect... figure it out.
      @user = nil
    end
    
    # Perform a command.
    # The command can be specified as a String or a set of tokens. Either form
    # should yield the same result, but using tokens can yield better
    # performance since it doesn't need to parse the command first.
    #
    # The command will be executed immediately regardless of game state.
    #
    # @example Send a command as a string
    #   character.perform "take the key"
    #
    # @example Send a command as a set of tokens
    #   character.perform :take, @key
    #
    def perform(*command)
      Director.dispatch(self, *command)
    end
    
    # Quietly perform a command.
    # This method executes the command exactly as #perform does, except it
    # buffers the resulting output instead of sending it to the user.
    #
    # @return [String] The output that resulted from performing the command.
    def quietly(*command)
      if @buffer_stack == 0
        @buffer = ""
      end
      @buffer_stack += 1
      self.perform *command
      @buffer_stack -= 1
      @buffer
    end
    
    # Send a message to the Character.
    # This method will automatically wrap the message in HTML paragraphs.
    # To send a message without paragraph formatting, use #stream instead.
    #
    # @param message [String]
    def tell(message)
      if user != nil and message.to_s != ''
        if @buffer_stack > 0
          @buffer += message
        else
          message = "<p>#{message}</p>"
          # This method uses String#gsub instead of String#gsub! for
          # compatibility with Opal.
          message = message.gsub(/\n\n/, '</p><p>')
          message = message.gsub(/\n/, '<br/>')
          user.stream.send message
        end
      end
    end
    
    # Send a message to the Character as raw text.
    # Unlike #tell, this method will not wrap the message in HTML paragraphs.
    #
    # @param message [String]
    def stream(message)
      user.stream.send message if !user.nil?
    end
    
    def destroy
      if @user != nil
        @user.quit
      end
      super
    end
    
    # Proceed to the next Action in the current stack.
    # This method is typically used in Action blocks to cascade through
    # multiple implementations of the same verb.
    #
    # @example Proceed through two implementations of a verb
    #   introduction do |actor|
    #     actor[:has_eaten] = false # Initial value
    #   end
    #   respond :eat do |actor|
    #     actor.tell "You eat something."
    #     actor[:has_eaten] = true
    #   end
    #   respond :eat do |actor|
    #     # This version will be executed first because it was implemented last
    #     if actor[:has_eaten]
    #       actor.tell "You already ate."
    #     else
    #       actor.proceed # Execute the previous implementation
    #     end
    #   end
    #
    def proceed
      return if delegate_stack.last.nil?
      delegate_stack.last.proceed
    end

    def cue scene_name
      @scene = scene_name
      @next_scene = nil
      plot.scenes[scene_name].start self
    end
    
    def prepare scene_name
      @next_scene = scene_name
    end

    def conclude scene_name
      scene = plot.scenes[scene_name]
      raise "#{scene_name} is not a conclusion" unless scene.kind_of?(Scene::Conclusion)
      cue scene_name
    end
    
    # Get the name of the character's current scene
    #
    # @return [Symbol] The name of the scene    
    def scene
      @scene
    end

    # Alias for Character#cue key
    def scene= key
      cue key.to_sym
    end
    
    def next_scene
      @next_scene
    end
    
    private
    def delegate_stack
      @delegate_stack ||= []
    end
    def last_order=(order)
      return if order.nil?
      @last_order = order
      if !order.action.meta? and !order.arguments[0].nil? and !order.arguments[0][0].nil? and order.arguments[0][0].kind_of?(Entity)
        @last_object = order.arguments[0][0]
      end
    end
  end

end
