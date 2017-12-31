module Gamefic
  module Sdk
    class DebugPlot < Gamefic::Plot
      def respond *args, &block
        result = super
        log_action result
        result
      end

      def meta *args, &block
        result = super
        log_action result
        result
      end

      def make *args, &block
        result = super
        entity_info.push({name: result.name, type: result.class.to_s, location: get_location(caller), filename: get_location(caller).split(':')[0..-2].join(':')})
        result
      end

      def entity_info
        @entity_info ||= []
      end

      def action_info
        action_meta.sort_by.with_index{|a, i| [a[:object].rank, i]}.reverse
      end

      private

      def action_meta
        @action_meta ||= []
      end

      def log_action result
        action_meta.push({
          verb: result.verb,
          signature: result.signature,
          location: get_location(caller),
          filename: get_location(caller).split(':')[0..-2].join(':'),
          line: get_location(caller).split(':').last,
          type: (result.meta? ? 'meta' : 'action'),
          object: result
        })
      end

      def get_location calls
        calls.each do |c|
          if c.end_with?(":in `stage'")
            return c[0..-12]
          end
        end
        nil
      end
    end
  end
end
