# frozen_string_literal: true

module Gamefic
  module Scene
    class Default
      # @return [Symbol]
      attr_reader :name

      # @param name [Symbol]
      # @param narrative [Narrative]
      # @param on_start [Proc, nil]
      # @param on_finish [Proc, nil]
      # @yieldparam [self]
      def initialize name, narrative, on_start: nil, on_finish: nil
        @name = name
        @narrative = narrative
        @start_blocks = []
        @finish_blocks = []
        @start_blocks.push on_start if on_start
        @finish_blocks.push on_finish if on_finish
        yield(self) if block_given?
      end

      # @return [String]
      def type
        @type ||= self.class.to_s.sub(/^Gamefic::Scene::/, '')
      end

      def new_props(context)
        self.class.props_class.new(name, type, **context)
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
      end

      # @param actor [Gamefic::Actor]
      # @param props [Props::Default]
      # @return [Boolean]
      def finish? actor, props
        props.input = actor.queue.shift
        true
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

      class << self
        protected

        def use_props_class klass
          @props_class = klass
        end
      end
    end
  end
end
