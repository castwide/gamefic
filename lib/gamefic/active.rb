#require 'gamefic/director'


module Gamefic
  class NotConclusionError < Exception
  end

  # The Active module gives entities the ability to perform actions and
  # participate in scenes.
  #
  module Active
    # @return [Gamefic::Action]
    attr_reader :last_action

    # @return [Gamefic::User::Base]
    attr_reader :user

    # @return [Gamefic::Scene::Base]
    attr_reader :scene

    attr_reader :next_scene

    # @return [Gamefic::Plot::Playbook]
    #attr_accessor :playbook

    # @return [Array<Gamefic::Plot::Playbook>]
    def playbooks
      @playbooks ||= []
    end

    def connect user
      @user = user
    end

    # An array of actions waiting to be performed.
    #
    # @return [Array<String>]
    def queue
      @queue ||= []
    end

    # A hash of values representing the state of a performing entity.
    #
    # @return [Hash]
    def state
      @state = {}
      @state.merge! scene.state unless scene.nil?
      @state[:output] = messages
      @state
    end

    # Send a message to the entity.
    # This method will automatically wrap the message in HTML paragraphs.
    # To send a message without paragraph formatting, use #stream instead.
    #
    # @param message [String]
    def tell(message)
      if buffer_stack > 0
        append_buffer message
      else
        super
      end
    end

    # Send a message to the Character as raw text.
    # Unlike #tell, this method will not wrap the message in HTML paragraphs.
    #
    # @param message [String]
    def stream(message)
      if buffer_stack > 0
        append_buffer message
      else
        super
      end
    end

    # Perform a command.
    # The command can be specified as a String or a verb with a list of
    # parameters. Either form should yield the same result, but the
    # verb/parameter form can yield better performance since it bypasses the
    # parser.
    #
    # The command will be executed immediately regardless of the entity's
    # state.
    #
    # @example Send a command as a string
    #   character.perform "take the key"
    #
    # @example Send a command as a verb with parameters
    #   character.perform :take, @key
    #
    # @return [Gamefic::Action]
    def perform(*command)
      actions = []
      playbooks.reverse.each { |p| actions.concat p.dispatch(self, *command) }
      execute_stack actions
    end
    
    # Quietly perform a command.
    # This method executes the command exactly as #perform does, except it
    # buffers the resulting output instead of sending it to the user.
    #
    # @return [String] The output that resulted from performing the command.
    def quietly(*command)
      if buffer_stack == 0
        clear_buffer
      end
      set_buffer_stack buffer_stack + 1
      self.perform *command
      set_buffer_stack buffer_stack - 1
      buffer
    end

    # Perform an action.
    # This is functionally identical to the `perform` method, except the
    # action must be declared as a verb with a list of parameters. Use
    # `perform` if you need to parse a string as a command.
    #
    # The command will be executed immediately regardless of the entity's
    # state.
    #
    # @example
    #   character.execute :take, @key
    #
    # @return [Gamefic::Action]
    def execute(verb, *params, quietly: false)
      actions = []
      playbooks.reverse.each { |p| actions.concat p.dispatch_from_params(self, verb, params) }
      execute_stack actions, quietly: quietly
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
        @scene.start
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
      (@scene.class == scene and @next_scene.nil?) or @next_scene == scene
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

    def accessible?
      false
    end

    def inspect
      to_s
    end

    private

    def execute_stack actions, quietly: false
      return nil if actions.empty?
      a = actions.first
      okay = true
      unless a.meta?
        playbooks.reverse.each do |playbook|
          okay = validate_playbook playbook, a
          break unless okay
        end
      end
      if okay
        performance_stack.push actions
        proceed quietly: quietly
        performance_stack.pop
      end
      a
    end

    def validate_playbook playbook, action
      okay = true
      playbook.validators.each { |v|
        result = v.call(self, action.verb, action.parameters)
        okay = (result != false)
        break unless okay
      }
      okay
    end

    def buffer_stack
      @buffer_stack ||= 0
    end

    def set_buffer_stack num
      @buffer_stack = num
    end

    def buffer
      @buffer ||= ''
    end

    def append_buffer str
      @buffer += str
    end

    def clear_buffer
      @buffer = '' unless @buffer.empty?
    end

    def performance_stack
      @performance_stack ||= []
    end
  end

end
