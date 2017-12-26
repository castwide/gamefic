module Gamefic
  module Sdk
    class DebugPlot < Gamefic::Plot
      def respond *args, &block
        result = super
        action_meta.push({verb: result.verb, signature: result.signature, location: get_location(caller), filename: get_location(caller).split(':')[0..-2].join(':'), line: get_location(caller).split(':').last, object: result})
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
        action_meta.sort { |a,b|
          if a[:object].rank == b[:object].rank
            b[:object].order_key <=> a[:object].order_key
          else
            b[:object].rank <=> a[:object].rank
          end
        }
      end

      private

      def action_meta
        @action_meta ||= []
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
