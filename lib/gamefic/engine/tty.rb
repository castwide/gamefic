require 'gamefic/user/tty'

module Gamefic

  # Extend Engine::Base to connect with User::Tty, which provides ANSI
  # formatting for HTML.
  #
  class Engine::Tty < Engine::Base
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
