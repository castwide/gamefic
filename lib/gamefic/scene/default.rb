# frozen_string_literal: true

module Gamefic
  module Scene
    # The base class for scenes. Authors can instantiate this class directly
    # and customize it with on_start and on_finish blocks.
    #
    class Default
      def initialize
      end

      def name
        self.class.scene_name
      end

      # @return [String]
      def type
        self.class.type
      end

      def new_props(**context)
        self.class.props_class.new(self, **context)
      end

      # @param actor [Gamefic::Actor]
      # @param props [Props::Default]
      # @return [void]
      def start actor, props
        props.output[:scene] = to_hash
        props.output[:prompt] = props.prompt
      end

      # @param actor [Gamefic::Actor]
      # @param props [Props::Default]
      # @return [void]
      def finish actor, props
        props.input = actor.queue.shift&.strip
      end

      def run_start_blocks actor, props
        self.class.start_blocks.each { |blk| execute(blk, actor, props) }
      end

      def run_finish_blocks actor, props
        self.class.finish_blocks.each { |blk| execute(blk, actor, props) }
      end

      def conclusion?
        is_a?(Conclusion)
      end

      def to_hash
        { name: name, type: type }
      end

      private

      def execute block, actor, props
        context = actor.match(self.class.context)
        if context
          Stage.run(context, actor, props, &block)
        else
          block[actor, props]
        end
      end

      class << self
        attr_reader :context

        def type
          'Default'
        end

        def props_class
          @props_class ||= Props::Default
        end

        def start_blocks
          @start_blocks ||= []
        end

        def finish_blocks
          @finish_blocks ||= []
        end

        def on_start &block
          start_blocks.push block
        end

        def on_finish &block
          finish_blocks.push block
        end

        def scene_name
          @scene_name || type
        end

        def bind klass, &block
          Class.new(self) do
            self.context = klass
            block&.call(self)
          end
        end

        def conclusion?
          false
        end

        def inherited klass
          super
          klass.use_props_class props_class
        end

        protected

        attr_writer :context

        def use_props_class klass
          @props_class = klass
        end
      end
    end
  end
end
