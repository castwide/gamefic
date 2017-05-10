module Gamefic
  module User
    class Web < Gamefic::User::Base
      def update state
        `Gamefic.update(#{state.to_json});`
      end

      def save filename, data
        data[:metadata] = GameficOpal.static_plot.metadata
        `Gamefic.save(filename, data);`
      end

      def restore filename
        data = `Gamefic.restore(filename);`
        return data
      end
    end
  end
end
