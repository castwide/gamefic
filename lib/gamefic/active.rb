require 'set'

module Gamefic
  class NotConclusionError < RuntimeError; end

  # The Active module gives entities the ability to perform actions and
  # participate in scenes. The Actor class, for example, is an Entity
  # subclass that includes this module.
  #
  module Active
    # The scene in which the entity is currently participating.
    #
    # @return [Gamefic::Scene::Base]
    attr_reader :scene

    # The most recently performed actions.
    #
    # The array gets reset every game turn by `Plot#ready`.
    #
    # @return [Array<Action>]
    def actions
      @actions ||= []
    end

    # The scene class that will be cued for this entity on the next turn.
    # Usually set with the #prepare method.
    #
    # @return [Class<Gamefic::Scene::Base>]
    attr_reader :next_scene

    attr_reader :next_options

    # The prompt for the previous scene.
    #
    # @return [String]
    attr_accessor :last_prompt

    # The input for the previous scene.
    #
    # @return [String]
    attr_accessor :last_input

    # The playbooks that will be used to perform commands.
    #
    # @return [Array<Gamefic::World::Playbook>]
    def playbooks
      @playbooks ||= []
    end

    def syntaxes
      playbooks.flat_map(&:syntaxes)
    end

    # An array of actions waiting to be performed.
    #
    # @return [Array<String>]
    def queue
      @queue ||= []
    end

    # A hash of values representing the state of a performing entity.
    #
    # @return [Hash{Symbol => Object}]
    def state
      @state ||= {}
    end

    def output
      @output ||= {}
    end

    # Send a message to the entity.
    # This method will automatically wrap the message in HTML paragraphs.
    # To send a message without paragraph formatting, use #stream instead.
    #
    # @param message [String]
    def tell(message)
      if buffer_stack > 0
        append_buffer format(message)
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
    #
    # The command's action will be executed immediately regardless of the
    # entity's state.
    #
    # @example Send a command as a string
    #   character.perform "take the key"
    #
    # @param command [String, Symbol]
    # @return [Gamefic::Action]
    def perform(*command)
      if command.length > 1
        STDERR.puts "[WARN] #{caller[0]}: Passing a verb and arguments to #perform is deprecated. Use #execute instead."
        execute command.first, *command[1..-1]
      else
        dispatchers.push Dispatcher.dispatch(self, command.first.to_s)
        proceed
        dispatchers.pop
      end
    end

    # Quietly perform a command.
    # This method executes the command exactly as #perform does, except it
    # buffers the resulting output instead of sending it to the user.
    #
    # @param command [String, Symbol]
    # @return [String] The output that resulted from performing the command.
    def quietly(*command)
      if command.length > 1
        STDERR.puts "#{caller[0]}: Passing a verb and arguments to #quietly is deprecated. Use #execute instead"
        execute command.first, *command[1..-1], quietly: true
      else
        dispatchers.push Dispatcher.dispatch(self, command.first.to_s)
        result = proceed quietly: true
        dispatchers.pop
        result
      end
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
    # @param verb [Symbol]
    # @param params [Array]
    # @params quietly [Boolean]
    # @return [Gamefic::Action]
    def execute(verb, *params, quietly: false)
      dispatchers.push Dispatcher.dispatch_from_params(self, verb, params)
      proceed quietly: quietly
      dispatchers.pop
    end

    # Proceed to the next Action in the current stack.
    # This method is typically used in Action blocks to cascade through
    # multiple implementations of the same verb.
    #
    # @example Proceed through two implementations of a verb
    #   introduction do |actor|
    #     actor[:has_eaten] = false # Initial value
    #   end
    #
    #   respond :eat do |actor|
    #     actor.tell "You eat something."
    #     actor[:has_eaten] = true
    #   end
    #
    #   respond :eat do |actor|
    #     # This version will be executed first because it was implemented last
    #     if actor[:has_eaten]
    #       actor.tell "You already ate."
    #     else
    #       actor.proceed # Execute the previous implementation
    #     end
    #   end
    #
    # @param quietly [Boolean] If true, return the action's output instead of appending it to #messages
    # @return [String, nil]
    def proceed quietly: false
      return if dispatchers.empty?
      a = dispatchers.last.next
      return if a.nil?
      prepare_buffer quietly
      a.execute
      flush_buffer quietly
    end

    # Immediately start a new scene for the character.
    # Use #prepare if you want to declare a scene to be started at the
    # beginning of the next turn.
    #
    # @param new_scene [Class<Scene::Base>]
    # @param data [Hash] Additional scene data
    def cue new_scene, **data
      @next_scene = nil
      if new_scene.nil?
        @scene = nil
      else
        @scene = new_scene.new(self, **data)
        @scene.start
      end
    end

    # Prepare a scene to be started for this character at the beginning of the
    # next turn. As opposed to #cue, a prepared scene will not start until the
    # current scene finishes.
    #
    # @param new_scene [Class<Scene::Base>]
    # @oaram data [Hash] Additional scene data
    def prepare new_scene, **data
      @next_scene = new_scene
      @next_options = data
    end

    # Return true if the character is expected to be in the specified scene on
    # the next turn.
    #
    # @return [Boolean]
    def will_cue? scene
      (@scene.class == scene and @next_scene.nil?) || @next_scene == scene
    end

    # Cue a conclusion. This method works like #cue, except it will raise a
    # NotConclusionError if the scene is not a Scene::Conclusion.
    #
    # @param new_scene [Class<Scene::Base>]
    # @oaram data [Hash] Additional scene data
    def conclude new_scene, **data
      raise NotConclusionError unless new_scene <= Scene::Conclusion
      cue new_scene, **data
    end

    # True if the character is in a conclusion.
    #
    # @return [Boolean]
    def concluded?
      !scene.nil? && scene.kind_of?(Scene::Conclusion)
    end

    def accessible?
      false
    end

    def inspect
      to_s
    end

    # Track the entity's performance of a scene.
    #
    def entered scene
      klass = (scene.is_a?(Gamefic::Scene::Base) ? scene.class : scene)
      entered_scenes.add klass
    end

    # Determine whether the entity has performed the specified scene.
    #
    # @return [Boolean]
    def entered? scene
      klass = (scene.kind_of?(Gamefic::Scene::Base) ? scene.class : scene)
      entered_scenes.include?(klass)
    end

    private

    def prepare_buffer quietly
      if quietly
        if buffer_stack == 0
          @buffer = ""
        end
        set_buffer_stack(buffer_stack + 1)
      end
    end

    def flush_buffer quietly
      if quietly
        set_buffer_stack(buffer_stack - 1)
        @buffer
      end
    end

    # @return [Set<Gamefic::Scene::Base>]
    def entered_scenes
      @entered_scenes ||= Set.new
    end

    def buffer_stack
      @buffer_stack ||= 0
    end

    def set_buffer_stack num
      @buffer_stack = num
    end

    # @return [String]
    def buffer
      @buffer ||= ''
    end

    def append_buffer str
      @buffer += str
    end

    def clear_buffer
      @buffer = ''
    end

    def dispatchers
      @dispatchers ||= []
    end
  end
end
