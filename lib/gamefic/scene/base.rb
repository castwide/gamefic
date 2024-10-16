# frozen_string_literal: true

module Gamefic
  module Scene
    # The base class for scenes. Authors can instantiate this class directly
    # and customize it with on_start and on_finish blocks.
    #
    class Base
      # @todo Code smell
      attr_writer :name

      attr_reader :actor, :props, :context

      def initialize actor, props = nil, **context
        @actor = actor
        @props = props || self.class.props_class.new(self)
        @context = context
      end

      def name
        @name ||= self.class.nickname
      end

      def rename name
        @name = name
      end

      # @return [String]
      def type
        self.class.type
      end

      # @param actor [Gamefic::Actor]
      # @param props [Props::Default]
      # @return [void]
      def start
        run_start_blocks
        props.output[:scene] = to_hash
        props.output[:prompt] = props.prompt
        props.output.merge!({
                              messages: actor.messages,
                              queue: actor.queue
                            })
        props.output.merge! actor.last_interaction
      end

      # @param actor [Gamefic::Actor]
      # @param props [Props::Default]
      # @return [void]
      def finish
        actor.flush
        props.input = actor.queue.shift&.strip
      end

      def run_start_blocks
        self.class.start_blocks.each { |blk| execute(blk) }
      end

      def run_finish_blocks
        self.class.finish_blocks.each { |blk| execute(blk) }
      end

      def conclusion?
        is_a?(Conclusion)
      end

      def to_hash
        { name: name, type: type }
      end

      private

      def execute(block)
        bound = actor.current || actor.narratives.first
        if bound
          Binding.new(bound, block).call(actor, props, context)
        else
          block[actor, props]
        end
      end

      class << self
        attr_reader :context, :nickname

        def type
          'Base'
        end

        def props_class
          @props_class ||= Props::Default
        end

        def rename(nickname)
          @nickname = nickname
        end

        def start_blocks
          @start_blocks ||= []
        end

        def finish_blocks
          @finish_blocks ||= []
        end

        def on_start(&block)
          start_blocks.push block
        end

        def on_finish(&block)
          finish_blocks.push block
        end

        def conclusion?
          false
        end

        def inherited(klass)
          super
          klass.use_props_class props_class
        end

        protected

        attr_writer :context

        def use_props_class(klass)
          @props_class = klass
        end
      end
    end
  end
end
