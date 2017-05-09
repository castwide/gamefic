#require 'gamefic/director'


module Gamefic
  class NotConclusionError < Exception
  end

  class Character < Entity
    #autoload :State, 'gamefic/character/state'

    attr_reader :queue, :user
    # @return [Gamefic::Action]
    attr_reader :last_action
    # @return [Entity,nil]
    attr_reader :last_object
    attr_accessor :object_of_pronoun
    attr_reader :scene
    attr_reader :next_scene
    attr_accessor :playbook
    
    #include Character::State

    def initialize(args = {})
      super
      @queue = Array.new
      @messages = ''
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
      @user = nil
    end

    # Send a message to the entity.
    # This method will automatically wrap the message in HTML paragraphs.
    # To send a message without paragraph formatting, use #stream instead.
    #
    # @param message [String]
    def tell(message)
      if @buffer_stack > 0
        @buffer += message
      else
        super
      end
    end

    # Send a message to the Character as raw text.
    # Unlike #tell, this method will not wrap the message in HTML paragraphs.
    #
    # @param message [String]
    def stream(message)
      if @buffer_stack > 0
        @buffer += message
      else
        super
      end
    end

    # Perform a command.
    # The command can be specified as a String or a set of tokens. Either form
    # should yield the same result, but using tokens can yield better
    # performance since it bypasses the parser.
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
      #Director.dispatch(self, *command)
      actions = playbook.dispatch(self, *command)
      a = actions.first
      okay = true
      unless a.meta?
        playbook.validators.each { |v|
          result = v.call(self, a.verb, a.parameters)
          okay = (result != false)
          break if not okay
        }
      end
      if okay
        performance_stack.push actions
        proceed
        performance_stack.pop
      end
      a
    end
    
    def flush
      super
      state.clear
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
    def proceed quietly: false
      #Director::Delegate.proceed_for self
      return if performance_stack.empty?
      a = performance_stack.last.shift
      unless a.nil?
        if quietly
          if @buffer_stack == 0
            @buffer = ""
          end
          @buffer_stack += 1
        end
        a.execute
        if quietly
          @buffer_stack -= 1
          @buffer
        end
      end
    end

    # Immediately start a new scene for the character.
    # Use #prepare if you want to declare a scene to be started at the
    # beginning of the next turn.
    #
    def cue new_scene
      @next_scene = nil
      if new_scene.nil?
        @scene = nil
      else
        @scene = new_scene.new(self)
      end
    end

    # Prepare a scene to be started for this character at the beginning of the
    # next turn.
    #
    def prepare s
      @next_scene = s
    end

    # Return true if the character is expected to be in the specified scene on
    # the next turn.
    #
    # @return [Boolean]
    def will_cue? scene
      (@scene == scene and @next_scene.nil?) or @next_scene == scene
    end

    # Cue a conclusion. This method works like #cue, except it will raise a
    # NotConclusionError if the scene is not a Scene::Conclusion.
    #
    def conclude scene
      raise NotConclusionError unless scene <= Scene::Conclusion
      cue scene
    end

    # True if the character is in a conclusion.
    #
    # @return [Boolean]
    def concluded?
      !scene.nil? and scene.kind_of?(Scene::Conclusion)
    end

    def performed order
      order.freeze
      @last_action = order
    end

    # Get the prompt that the user should see for the current scene.
    #
    # @return [String]
    #def prompt
    #  scene.nil? ? '>' : scene.prompt
    #end

    def state
      @state ||= {}
      @state.merge! scene.state unless scene.nil?
      @state.merge! output: messages
    end

    def accessible?
      false
    end

    def inspect
      to_s
    end

    private

    def delegate_stack
      @delegate_stack ||= []
    end

    def performance_stack
      @performance_stack ||= []
    end
  end

end
