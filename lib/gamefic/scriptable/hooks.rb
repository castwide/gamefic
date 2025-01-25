# frozen_string_literal: true

module Gamefic
  module Scriptable
    # Scriptable hook methods are class methods that define procs to be
    # executed in response to various game events.
    #
    module Hooks
      # Define a callback to be executed before a command is processed. The
      # callback accepts two parameters, the Actor and the Command.
      #
      # The optional verbs parameter can be used to restrict the callback to
      # commands that use one of the specified verbs. If no verbs are provided,
      # the callback will be executed before every command.
      #
      # Calling Command#cancel will prevent the command from being performed.
      #
      # @example Cancel non-meta commands when the actor does not have a parent
      #   before_command do |actor, command|
      #     next if actor.parent || command.meta?
      #
      #     actor.tell "You can't do anything while you're in limbo."
      #     command.cancel
      #   end
      #
      # @param verbs [Array<Symbol>]
      # @yieldparam [Actor]
      # @yieldparam [Command]
      # @yieldself [Object<self>]
      def before_command(*verbs, &block)
        before_commands.push(proc do |actor, command|
          instance_exec(actor, command, &block) if verbs.empty? || verbs.include?(command.verb)
        end)
      end

      # Define a callback to be executed after a command is processed. The
      # callback accepts two parameters, the Actor and the Command.
      #
      # The optional verbs parameter can be used to restrict the callback to
      # commands that use one of the specified verbs. If no verbs are provided,
      # the callback will be executed after every command.
      #
      # @param verbs [Array<Symbol>]
      # @yieldparam [Actor]
      # @yieldparam [Command]
      # @yieldself [Object<self>]
      def after_command(*verbs, &block)
        after_commands.push(proc do |actor, command|
          instance_exec(actor, command, &block) if verbs.empty? || verbs.include?(command.verb)
        end)
      end

      # Define a callback to be executed after a scene starts.
      #
      # @yieldself [Object<self>]
      def on_ready(&block)
        ready_blocks.push block
      end

      # Define a callback to be executed for each participating player after
      # a scene starts.
      #
      # @yieldparam [Actor]
      # @yieldself [Object<self>]
      def on_player_ready(&block)
        ready_blocks.push(proc { players.each { |player| instance_exec(player, &block) } })
      end

      # Define a callback to be executed after a scene finishes.
      #
      # @yieldself [Object<self>]
      def on_update(&block)
        update_blocks.push block
      end

      # Define a callback to be executed for each participating player after
      # a scene finishes.
      #
      # @yieldparam [Actor]
      # @yieldself [Object<self>]
      def on_player_update(&block)
        update_blocks.push(proc { players.each { |player| instance_exec(player, &block) } })
      end

      # Define a callback that modifies the output sent to the player at the
      # beginning of a game turn. The callback accepts two parameters, the
      # Actor and the Props::Output.
      #
      # Narrators execute player_output blocks after starting a scene and
      # executing ready blocks. The output gets sent to players' game clients
      # as JSON objects to be rendered before prompting the player for input.
      #
      # @example Add a player's parent to the output as a custom hash value.
      #   on_player_output do |actor, output|
      #     output[:parent_name] = actor.parent&.name
      #   end
      #
      # @yieldparam [Actor]
      # @yieldparam [Props::Output]
      # @yieldself [Object<self>]
      def on_player_output(&block)
        player_output_blocks.push(block)
      end

      # Define a callback that gets executed when a narrative reaches a
      # conclusion.
      #
      # @yieldself [Object<self>]
      def on_conclude(&block)
        conclude_blocks.push(block)
      end

      # Define a callback that gets executed when a player reaches a 
      # conclusion.
      #
      # @note A player can conclude participation in a narrative without the
      #   narrative itself concluding.
      #
      # @yieldparam [Actor]
      # @yieldself [Object<self>]
      def on_player_conclude(&block)
        player_conclude_blocks.push(block)
      end

      # @return [Array<Proc>]
      def before_commands
        @before_commands ||= []
      end

      # @return [Array<Proc>]
      def after_commands
        @after_commands ||= []
      end

      # @return [Array<Proc>]
      def ready_blocks
        @ready_blocks ||= []
      end

      # @return [Array<Proc>]
      def update_blocks
        @update_blocks ||= []
      end

      # @return [Array<Proc>]
      def player_output_blocks
        @player_output_blocks ||= []
      end

      # @return [Array<Proc>]
      def conclude_blocks
        @conclude_blocks ||= []
      end

      # @return [Array<Proc>]
      def player_conclude_blocks
        @player_conclude_blocks ||= []
      end
    end
  end
end
