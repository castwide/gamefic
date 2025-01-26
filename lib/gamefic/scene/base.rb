# frozen_string_literal: true

module Gamefic
  module Scene
    # The base class for scenes. Authors can instantiate this class directly
    # and customize it with on_start and on_finish blocks.
    #
    class Base
      # @todo Code smell
      attr_writer :name

      attr_reader :actor, :narrative, :props, :context

      # @param actor [Actor]
      # @param narrative [Narrative]
      # @param props [Props::Default]
      def initialize(actor, narrative = nil, props = nil, **context)
        @actor = actor
        @narrative = narrative
        @props = props || self.class.props_class.new
        @context = context
      end

      def name
        @name ||= self.class.nickname
      end

      def rename(name)
        @name = name
      end

      # @return [String]
      def type
        self.class.type
      end

      # @return [Props::Default]
      def start
        run_start_blocks
        props
      end

      # @return [void]
      def finish
        run_finish_blocks
      end

      def to_hash
        { name: name, type: type }
      end

      def self.inherited(klass)
        super
        klass.use_props_class props_class
        klass.start_blocks.concat start_blocks
        klass.finish_blocks.concat finish_blocks
      end

      private

      def execute(block)
        Binding.new(narrative, block).call(actor, props, context)
      end

      def run_start_blocks
        self.class.start_blocks.each { |blk| execute(blk) }
      end

      def run_finish_blocks
        self.class.finish_blocks.each { |blk| execute(blk) }
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

        # @return [Array<Proc>]
        def start_blocks
          @start_blocks ||= []
        end

        # @return [Array<Proc>]
        def finish_blocks
          @finish_blocks ||= []
        end

        # @yieldparam [Actor] The scene's actor
        # @yieldparam [Props::Default] The scene's props
        # @yieldparam [Hash] Additional context
        def on_start(&block)
          start_blocks.push block
        end

        # @yieldparam [Actor] The scene's actor
        # @yieldparam [Props::Default] The scene's props
        # @yieldparam [Hash] Additional context
        def on_finish(&block)
          finish_blocks.push block
        end

        protected

        attr_writer :context

        # @param klass [Class<Props::Default>]
        def use_props_class(klass)
          @props_class = klass
        end
      end
    end
  end
end
