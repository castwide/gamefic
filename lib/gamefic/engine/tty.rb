module Gamefic

  class Engine::Tty < Engine::Base
    def post_initialize
      user_class = Gamefic::User::Tty
    end
  end

end
