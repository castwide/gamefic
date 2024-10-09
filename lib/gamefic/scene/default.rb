# frozen_string_literal: true

module Gamefic
  module Scene
    # The base class for scenes. Authors can instantiate this class directly
    # and customize it with on_start and on_finish blocks.
    #
    class Default
      # @param name [Symbol, nil]
      # @param narrative [Narrative]
      # @yieldparam [self]
      def initialize
        @start_blocks = self.class.start_blocks
        @finish_blocks = self.class.finish_blocks
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
        @start_blocks.each { |blk| execute(blk, actor, props) }
      end

      def run_finish_blocks actor, props
        @finish_blocks.each { |blk| execute(blk, actor, props) }
      end

      def conclusion?
        is_a?(Conclusion)
      end

      def to_hash
        { name: name, type: type }
      end

      private

      def execute block, actor, props
        block[actor, props]
      end

      class << self
        def type
          'Default'
        end

        def props_class
          @props_class ||= Props::Default
        end

        def start_blocks
          protected_start_blocks.clone
        end

        def finish_blocks
          protected_finish_blocks.clone
        end

        def on_start &block
          protected_start_blocks.push block
        end

        def on_finish &block
          protected_finish_blocks.push block
        end

        def scene_name
          @scene_name || type
        end

        def bind narrative, &block
          Class.new(self) do
            define_method(:execute) do |block, actor, props|
              Stage.run(narrative, actor, props, &block)
            end

            block&.call(self)
          end
        end

        def update_narrative narr
          class_exec do
            define_method(:execute) do |block, actor, props|
              Stage.run(narr, actor, props, &block)
            end
          end
        end

        def conclusion?
          false
        end

        def inherited klass
          klass.use_props_class props_class
        end

        protected

        def set_scene_name name
          @scene_name = name
        end

        def use_props_class klass
          @props_class = klass
        end

        def protected_start_blocks
          @protected_start_blocks ||= []
        end

        def protected_finish_blocks
          @protected_finish_blocks ||= []
        end
      end
    end
  end
end
