module Gamefic
  module Block
    module ScriptMethods
      include Logging
      include Delegatable::Actions
      include Delegatable::Queries
      include Delegatable::Scenes

      def make(...)
        logger.warn 'Making entities from scripts is not recommended. Snapshots may not restore properly. ' \
                    'Use `seed` for static entities or rule blocks for dynamic entities.'
        super
      end
    end
  end
end
