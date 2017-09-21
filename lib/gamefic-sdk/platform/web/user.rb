module Gamefic
  module User
    class Web < Gamefic::User::Base
      def update
        #`Gamefic.update(#{character.state.to_json});`
      end

      def save filename, data
        `Gamefic.save(filename, data);`
      end

      def restore filename
        data = `Gamefic.restore(filename);`
        return data
      end
    end
  end
end
