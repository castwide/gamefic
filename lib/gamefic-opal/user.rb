module Gamefic
  module Opal
    class User < Gamefic::User::Base
      def update
        #`Gamefic.update(#{character.state.to_json});`
      end

      def save filename, data
        `localStorage.setItem(filename, data);`
      end

      def restore filename
        `localStorage.getItem(filename);`
      end
    end
  end
end
