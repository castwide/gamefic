require 'gamefic/user/tty'

module Gamefic

  class Engine::Tty < Engine::Base
    def post_initialize
      set_user_class Gamefic::User::Tty
    end
  end

end
