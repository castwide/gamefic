require 'gamefic/user/tty'

module Gamefic
  module Tty
    # Extend Engine::Base to connect with User::Tty, which provides ANSI
    # formatting for HTML.
    #
    # @note Due to their dependency on io/console, User::Tty and Engine::Tty are
    #   not included in the core Gamefic library. `require gamefic/tty` if you
    #   need them.
    #
    class Engine < Gamefic::Engine::Base
      def post_initialize
        self.user_class = Gamefic::User::Tty
      end

      def self.start plot
        engine = self.new(plot)
        engine.connect
        engine.run
      end
    end
  end
end
