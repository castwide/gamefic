module Gamefic
  module User
    class Sinatra < Gamefic::User::Base
      def update
        # Nothing to do?
      end

      def save filename, snapshot
        File.open(filename, 'w') do |file|
          file << snapshot.to_json
        end
      end

      def restore filename
        json = File.read(filename)
        snapshot = JSON.parse(json, symbolize_names: true)
        engine.plot.restore snapshot
      end
    end
  end
end
