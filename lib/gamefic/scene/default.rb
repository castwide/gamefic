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
      def initialize name, narrative, &block
        @name = name || self.class.default_name
        @narrative = narrative
        @start_blocks = self.class.start_blocks
        @finish_blocks = self.class.finish_blocks
        Stage.run(narrative, self, &block) if block
      end

      # @return [String]
      def type
        @type ||= self.class.to_s.sub(/^Gamefic::Scene::/, '')
      end

      def new_props(**context)
        self.class.props_class.new(self, **context)
      end

      def on_start &block
        @start_blocks.push block
      end

      def on_finish &block
        @finish_blocks.push block
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
        @start_blocks.each { |blk| Stage.run(@narrative, actor, props, &blk) }
      end

      def run_finish_blocks actor, props
        @finish_blocks.each { |blk| Stage.run(@narrative, actor, props, &blk) }
      end

      def self.props_class
        @props_class ||= Props::Default
      end

      def conclusion?
        is_a?(Conclusion)
      end

      def to_hash
        { name: name, type: type }
      end

      class << self
        def default_name
          @default_name ||= self.class.name.to_s.gsub('::', '_').to_sym
        end

        def start_blocks
          protected_start_blocks.clone
        end

        def finish_blocks
          protected_finish_blocks.clone
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

        def on_start &block
          protected_start_blocks.push block
        end

        def on_finish &block
          protected_finish_blocks.push block
        end
      end
    end
  end
end
