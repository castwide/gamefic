# frozen_string_literal: true

module Gamefic
  module Scene
    # The base class for scenes. Authors can instantiate this class directly
    # and customize it with on_start and on_finish blocks.
    #
    class Default
      # @return [Symbol]
      attr_reader :name

      # @param name [Symbol, nil]
      # @param narrative [Narrative]
      # @yieldparam [self]
      def initialize name, &block
        @name = name || self.class.name
        @start_blocks = self.class.start_blocks
        @finish_blocks = self.class.finish_blocks
        Stage.run(self, self, &block) if block
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

        def default_name
          @default_name ||= self.class.name.to_s.gsub('::', '_').to_sym
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

        def name
          @name || super
        end

        def hydrate name, narrative, &block
          super_props = props_class
          Class.new(self) do
            use_props_class super_props
            @name = name

            define_method(:execute) do |block, actor, props|
              Stage.run(narrative, actor, props, &block)
            end

          end.tap { |klass| Stage.run(narrative, klass, &block) if block }
        end

        def conclusion?
          false
        end

        protected

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
